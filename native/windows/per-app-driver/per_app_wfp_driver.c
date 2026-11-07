#include <ntifs.h>
#include <ntddk.h>
#include <ndis.h>
#include <fwpmk.h>
#include <fwpsk.h>
#include <wdmsec.h>

#define HARMONEY_DEVICE_NAME L"\\Device\\HarmoneyPerAppWfp"
#define HARMONEY_DOS_NAME L"\\DosDevices\\HarmoneyPerAppWfp"
#define HARMONEY_PROXY_PORT 47890
#define HARMONEY_UDP_PROXY_PORT 47891
#define HARMONEY_UDP_MAP_CAPACITY 512
#define HARMONEY_UDP_MAP_TTL (120ULL * 10000000ULL)
#define HARMONEY_POOL_TAG 'pMMW'
#define IOCTL_HARMONEY_SET_PROXY_PID \
  CTL_CODE(FILE_DEVICE_NETWORK, 0x801, METHOD_BUFFERED, FILE_WRITE_DATA)
#define IOCTL_HARMONEY_QUERY_UDP_DESTINATION \
  CTL_CODE(FILE_DEVICE_NETWORK, 0x802, METHOD_BUFFERED, FILE_READ_DATA)

static const GUID HARMONEY_WFP_PROVIDER = {
    0x6f583d41, 0x0a8c, 0x4e88, {0x9c, 0x30, 0x2c, 0x20, 0xa4, 0x98, 0x11, 0x71}};
static const GUID HARMONEY_CONNECT_REDIRECT_V4 = {
    0x6f583d42, 0x0a8c, 0x4e88, {0x9c, 0x30, 0x2c, 0x20, 0xa4, 0x98, 0x11, 0x71}};
static const GUID HARMONEY_CONNECT_REDIRECT_V6 = {
    0x6f583d43, 0x0a8c, 0x4e88, {0x9c, 0x30, 0x2c, 0x20, 0xa4, 0x98, 0x11, 0x71}};
static const GUID HARMONEY_DEVICE_CLASS = {
    0x6f583d44, 0x0a8c, 0x4e88, {0x9c, 0x30, 0x2c, 0x20, 0xa4, 0x98, 0x11, 0x71}};

static PDEVICE_OBJECT g_device;
static HANDLE g_redirect_handle;
static UINT32 g_callout_v4;
static UINT32 g_callout_v6;
static volatile LONG64 g_proxy_pid;
typedef struct _HARMONEY_UDP_MAP_ENTRY {
  SOCKADDR_STORAGE local;
  SOCKADDR_STORAGE remote;
  ULONGLONG last_seen;
  BOOLEAN active;
} HARMONEY_UDP_MAP_ENTRY;
static HARMONEY_UDP_MAP_ENTRY g_udp_maps[HARMONEY_UDP_MAP_CAPACITY];
static KSPIN_LOCK g_udp_maps_lock;

static VOID SetBlocked(FWPS_CLASSIFY_OUT0* classify_out) {
  if ((classify_out->rights & FWPS_RIGHT_ACTION_WRITE) != 0) {
    classify_out->actionType = FWP_ACTION_BLOCK;
    classify_out->rights &= ~FWPS_RIGHT_ACTION_WRITE;
  }
}

static VOID SetPermitted(FWPS_CLASSIFY_OUT0* classify_out) {
  if ((classify_out->rights & FWPS_RIGHT_ACTION_WRITE) != 0) {
    classify_out->actionType = FWP_ACTION_PERMIT;
    classify_out->rights &= ~FWPS_RIGHT_ACTION_WRITE;
  }
}

static VOID SetLoopbackEndpoint(SOCKADDR_STORAGE* endpoint,
                                ADDRESS_FAMILY family, USHORT port) {
  RtlZeroMemory(endpoint, sizeof(*endpoint));
  if (family == AF_INET) {
    SOCKADDR_IN* v4 = (SOCKADDR_IN*)endpoint;
    v4->sin_family = AF_INET;
    v4->sin_port = RtlUshortByteSwap(port);
    v4->sin_addr.s_addr = INADDR_LOOPBACK;
  } else {
    SOCKADDR_IN6* v6 = (SOCKADDR_IN6*)endpoint;
    v6->sin6_family = AF_INET6;
    v6->sin6_port = RtlUshortByteSwap(port);
    v6->sin6_addr.u.Byte[15] = 1;
  }
}

static USHORT EndpointPort(const SOCKADDR_STORAGE* endpoint) {
  if (endpoint->ss_family == AF_INET)
    return ((const SOCKADDR_IN*)endpoint)->sin_port;
  if (endpoint->ss_family == AF_INET6)
    return ((const SOCKADDR_IN6*)endpoint)->sin6_port;
  return 0;
}

static BOOLEAN SameEndpoint(const SOCKADDR_STORAGE* left,
                            const SOCKADDR_STORAGE* right) {
  if (left->ss_family != right->ss_family ||
      EndpointPort(left) != EndpointPort(right))
    return FALSE;
  if (left->ss_family == AF_INET)
    return ((const SOCKADDR_IN*)left)->sin_addr.s_addr ==
           ((const SOCKADDR_IN*)right)->sin_addr.s_addr;
  if (left->ss_family == AF_INET6) {
    const SOCKADDR_IN6* l = (const SOCKADDR_IN6*)left;
    const SOCKADDR_IN6* r = (const SOCKADDR_IN6*)right;
    return l->sin6_scope_id == r->sin6_scope_id &&
           RtlCompareMemory(&l->sin6_addr, &r->sin6_addr,
                            sizeof(l->sin6_addr)) == sizeof(l->sin6_addr);
  }
  return FALSE;
}

static BOOLEAN StoreUdpMap(const SOCKADDR_STORAGE* local,
                           const SOCKADDR_STORAGE* remote) {
  const ULONGLONG now = KeQueryInterruptTime();
  ULONG selected = HARMONEY_UDP_MAP_CAPACITY;
  ULONGLONG oldest = MAXULONGLONG;
  KIRQL old_irql;
  if ((local->ss_family != AF_INET && local->ss_family != AF_INET6) ||
      EndpointPort(local) == 0 ||
      (remote->ss_family != AF_INET && remote->ss_family != AF_INET6))
    return FALSE;

  KeAcquireSpinLock(&g_udp_maps_lock, &old_irql);
  for (ULONG i = 0; i < HARMONEY_UDP_MAP_CAPACITY; ++i) {
    HARMONEY_UDP_MAP_ENTRY* entry = &g_udp_maps[i];
    if (entry->active && now - entry->last_seen > HARMONEY_UDP_MAP_TTL)
      entry->active = FALSE;
    if (entry->active && SameEndpoint(&entry->local, local)) {
      // A single local UDP endpoint can address multiple peers with sendto.
      // Do not guess which destination a shared proxy datagram belongs to.
      if (!SameEndpoint(&entry->remote, remote)) {
        KeReleaseSpinLock(&g_udp_maps_lock, old_irql);
        return FALSE;
      }
      selected = i;
      break;
    }
    if (!entry->active && selected == HARMONEY_UDP_MAP_CAPACITY) selected = i;
    if (entry->active && entry->last_seen < oldest) {
      oldest = entry->last_seen;
      if (selected == HARMONEY_UDP_MAP_CAPACITY) selected = i;
    }
  }
  if (selected < HARMONEY_UDP_MAP_CAPACITY) {
    HARMONEY_UDP_MAP_ENTRY* entry = &g_udp_maps[selected];
    RtlZeroMemory(entry, sizeof(*entry));
    RtlCopyMemory(&entry->local, local, sizeof(*local));
    RtlCopyMemory(&entry->remote, remote, sizeof(*remote));
    entry->last_seen = now;
    entry->active = TRUE;
  }
  KeReleaseSpinLock(&g_udp_maps_lock, old_irql);
  return selected < HARMONEY_UDP_MAP_CAPACITY;
}

static NTSTATUS QueryUdpDestination(const SOCKADDR_STORAGE* local,
                                   SOCKADDR_STORAGE* remote) {
  const ULONGLONG now = KeQueryInterruptTime();
  ULONG matches = 0;
  KIRQL old_irql;
  KeAcquireSpinLock(&g_udp_maps_lock, &old_irql);
  for (ULONG i = 0; i < HARMONEY_UDP_MAP_CAPACITY; ++i) {
    HARMONEY_UDP_MAP_ENTRY* entry = &g_udp_maps[i];
    if (entry->active && now - entry->last_seen > HARMONEY_UDP_MAP_TTL)
      entry->active = FALSE;
    if (!entry->active || entry->local.ss_family != local->ss_family ||
        EndpointPort(&entry->local) != EndpointPort(local))
      continue;
    if (!SameEndpoint(&entry->local, local)) continue;
    *remote = entry->remote;
    entry->last_seen = now;
    ++matches;
  }
  KeReleaseSpinLock(&g_udp_maps_lock, old_irql);
  return matches == 1 ? STATUS_SUCCESS
                      : (matches == 0 ? STATUS_NOT_FOUND : STATUS_OBJECT_NAME_COLLISION);
}

static VOID ClearUdpMaps(VOID) {
  KIRQL old_irql;
  KeAcquireSpinLock(&g_udp_maps_lock, &old_irql);
  RtlZeroMemory(g_udp_maps, sizeof(g_udp_maps));
  KeReleaseSpinLock(&g_udp_maps_lock, old_irql);
}

static VOID NTAPI ClassifyConnectRedirect(
    const FWPS_INCOMING_VALUES0* in_fixed_values,
    const FWPS_INCOMING_METADATA_VALUES0* in_meta_values,
    VOID* layer_data,
    const VOID* classify_context,
    const FWPS_FILTER1* filter,
    UINT64 flow_context,
    FWPS_CLASSIFY_OUT0* classify_out) {
  UNREFERENCED_PARAMETER(layer_data);
  UNREFERENCED_PARAMETER(flow_context);

  if (classify_out == NULL ||
      (classify_out->rights & FWPS_RIGHT_ACTION_WRITE) == 0) {
    return;
  }

  if (filter == NULL || in_fixed_values == NULL || classify_context == NULL) {
    SetBlocked(classify_out);
    return;
  }

  UINT32 protocol_index = FWPS_FIELD_ALE_CONNECT_REDIRECT_V4_IP_PROTOCOL;
  ADDRESS_FAMILY family = AF_INET;
  if (in_fixed_values->layerId == FWPS_LAYER_ALE_CONNECT_REDIRECT_V6) {
    protocol_index = FWPS_FIELD_ALE_CONNECT_REDIRECT_V6_IP_PROTOCOL;
    family = AF_INET6;
  }
  const UINT8 protocol = in_fixed_values->incomingValue[protocol_index].value.uint8;
  if (protocol != IPPROTO_TCP && protocol != IPPROTO_UDP) {
    SetPermitted(classify_out);
    return;
  }

  if (in_meta_values != NULL &&
      FWPS_IS_METADATA_FIELD_PRESENT(in_meta_values,
                                     FWPS_METADATA_FIELD_REDIRECT_RECORD_HANDLE)) {
    const FWPS_CONNECTION_REDIRECT_STATE state =
        FwpsQueryConnectionRedirectState0(in_meta_values->redirectRecords,
                                          g_redirect_handle, NULL);
    if (state == FWPS_CONNECTION_REDIRECTED_BY_SELF ||
        state == FWPS_CONNECTION_PREVIOUSLY_REDIRECTED_BY_SELF) {
      SetPermitted(classify_out);
      return;
    }
  }

  const LONG64 proxy_pid = InterlockedCompareExchange64(&g_proxy_pid, 0, 0);
  if (proxy_pid <= 0 || proxy_pid > MAXULONG) {
    // The selected application must not silently fall back into the VPN when
    // its direct-egress relay is not running.
    SetBlocked(classify_out);
    return;
  }

  UINT64 classify_handle = 0;
  NTSTATUS status = FwpsAcquireClassifyHandle0((VOID*)classify_context, 0,
                                                &classify_handle);
  if (!NT_SUCCESS(status)) {
    SetBlocked(classify_out);
    return;
  }

  FWPS_CONNECT_REQUEST0* request = NULL;
  status = FwpsAcquireWritableLayerDataPointer0(
      classify_handle, filter->filterId, 0, (PVOID*)&request, classify_out);
  if (!NT_SUCCESS(status) || request == NULL) {
    FwpsReleaseClassifyHandle0(classify_handle);
    SetBlocked(classify_out);
    return;
  }

  SOCKADDR_STORAGE* redirect_context = (SOCKADDR_STORAGE*)ExAllocatePool2(
      POOL_FLAG_NON_PAGED, sizeof(SOCKADDR_STORAGE) * 2, HARMONEY_POOL_TAG);
  if (redirect_context == NULL) {
    classify_out->actionType = FWP_ACTION_BLOCK;
    classify_out->rights |= FWPS_RIGHT_ACTION_WRITE;
    FwpsApplyModifiedLayerData0(classify_handle, request, 0);
    FwpsReleaseClassifyHandle0(classify_handle);
    return;
  }
  RtlZeroMemory(redirect_context, sizeof(SOCKADDR_STORAGE) * 2);
  RtlCopyMemory(&redirect_context[0], &request->remoteAddressAndPort,
                sizeof(SOCKADDR_STORAGE));
  RtlCopyMemory(&redirect_context[1], &request->localAddressAndPort,
                sizeof(SOCKADDR_STORAGE));

  if (protocol == IPPROTO_UDP &&
      !StoreUdpMap(&request->localAddressAndPort,
                   &request->remoteAddressAndPort)) {
    ExFreePoolWithTag(redirect_context, HARMONEY_POOL_TAG);
    classify_out->actionType = FWP_ACTION_BLOCK;
    classify_out->rights |= FWPS_RIGHT_ACTION_WRITE;
    FwpsApplyModifiedLayerData0(classify_handle, request, 0);
    FwpsReleaseClassifyHandle0(classify_handle);
    return;
  }

  SetLoopbackEndpoint(&request->remoteAddressAndPort, family,
                      protocol == IPPROTO_UDP ? HARMONEY_UDP_PROXY_PORT
                                              : HARMONEY_PROXY_PORT);
  request->localRedirectTargetPID = (DWORD)proxy_pid;
  request->localRedirectHandle = g_redirect_handle;
  request->localRedirectContext = redirect_context;
  request->localRedirectContextSize = sizeof(SOCKADDR_STORAGE) * 2;

  // The writable-layer call clears ACTION_WRITE. Permit only after the
  // modified endpoint is accepted by WFP.
  classify_out->actionType = FWP_ACTION_PERMIT;
  classify_out->rights |= FWPS_RIGHT_ACTION_WRITE;
  FwpsApplyModifiedLayerData0(
      classify_handle, request,
      FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS);
  FwpsReleaseClassifyHandle0(classify_handle);
}

static NTSTATUS NTAPI NotifyCallout(FWPS_CALLOUT_NOTIFY_TYPE notify_type,
                                    const GUID* filter_key,
                                    FWPS_FILTER1* filter) {
  UNREFERENCED_PARAMETER(notify_type);
  UNREFERENCED_PARAMETER(filter_key);
  UNREFERENCED_PARAMETER(filter);
  return STATUS_SUCCESS;
}

static NTSTATUS RegisterCallout(const GUID* key, UINT32* callout_id) {
  FWPS_CALLOUT1 callout;
  RtlZeroMemory(&callout, sizeof(callout));
  callout.calloutKey = *key;
  callout.classifyFn = ClassifyConnectRedirect;
  callout.notifyFn = NotifyCallout;
  return FwpsCalloutRegister1(g_device, &callout, callout_id);
}

static VOID CompleteIrp(PIRP irp, NTSTATUS status, ULONG_PTR information) {
  irp->IoStatus.Status = status;
  irp->IoStatus.Information = information;
  IoCompleteRequest(irp, IO_NO_INCREMENT);
}

static NTSTATUS DispatchCreateClose(PDEVICE_OBJECT device, PIRP irp) {
  UNREFERENCED_PARAMETER(device);
  CompleteIrp(irp, STATUS_SUCCESS, 0);
  return STATUS_SUCCESS;
}

static NTSTATUS DispatchDeviceControl(PDEVICE_OBJECT device, PIRP irp) {
  UNREFERENCED_PARAMETER(device);
  PIO_STACK_LOCATION stack = IoGetCurrentIrpStackLocation(irp);
  const ULONG code = stack->Parameters.DeviceIoControl.IoControlCode;
  if (irp->AssociatedIrp.SystemBuffer == NULL) {
    CompleteIrp(irp, STATUS_INVALID_PARAMETER, 0);
    return STATUS_INVALID_PARAMETER;
  }

  if (code == IOCTL_HARMONEY_QUERY_UDP_DESTINATION) {
    if (stack->Parameters.DeviceIoControl.InputBufferLength <
            sizeof(SOCKADDR_STORAGE) ||
        stack->Parameters.DeviceIoControl.OutputBufferLength <
            sizeof(SOCKADDR_STORAGE) ||
        IoGetRequestorProcessId(irp) !=
            (HANDLE)InterlockedCompareExchange64(&g_proxy_pid, 0, 0)) {
      CompleteIrp(irp, STATUS_ACCESS_DENIED, 0);
      return STATUS_ACCESS_DENIED;
    }
    SOCKADDR_STORAGE local = *(SOCKADDR_STORAGE*)irp->AssociatedIrp.SystemBuffer;
    SOCKADDR_STORAGE remote;
    RtlZeroMemory(&remote, sizeof(remote));
    const NTSTATUS status = QueryUdpDestination(&local, &remote);
    if (NT_SUCCESS(status)) {
      RtlCopyMemory(irp->AssociatedIrp.SystemBuffer, &remote, sizeof(remote));
      CompleteIrp(irp, STATUS_SUCCESS, sizeof(remote));
      return STATUS_SUCCESS;
    }
    CompleteIrp(irp, status, 0);
    return status;
  }

  if (code != IOCTL_HARMONEY_SET_PROXY_PID ||
      stack->Parameters.DeviceIoControl.InputBufferLength < sizeof(ULONG)) {
    CompleteIrp(irp, STATUS_INVALID_PARAMETER, 0);
    return STATUS_INVALID_PARAMETER;
  }

  const ULONG proxy_pid = *(ULONG*)irp->AssociatedIrp.SystemBuffer;
  if (proxy_pid == 0) {
    InterlockedExchange64(&g_proxy_pid, 0);
    ClearUdpMaps();
    CompleteIrp(irp, STATUS_SUCCESS, sizeof(ULONG));
    return STATUS_SUCCESS;
  }

  InterlockedExchange64(&g_proxy_pid, proxy_pid);
  CompleteIrp(irp, STATUS_SUCCESS, sizeof(ULONG));
  return STATUS_SUCCESS;
}

static VOID UnloadDriver(PDRIVER_OBJECT driver) {
  UNICODE_STRING dos_name;
  RtlInitUnicodeString(&dos_name, HARMONEY_DOS_NAME);
  IoDeleteSymbolicLink(&dos_name);

  if (g_callout_v6 != 0) FwpsCalloutUnregisterById0(g_callout_v6);
  if (g_callout_v4 != 0) FwpsCalloutUnregisterById0(g_callout_v4);
  if (g_redirect_handle != NULL) FwpsRedirectHandleDestroy0(g_redirect_handle);
  if (g_device != NULL) IoDeleteDevice(g_device);
  UNREFERENCED_PARAMETER(driver);
}

NTSTATUS DriverEntry(PDRIVER_OBJECT driver, PUNICODE_STRING registry_path) {
  UNREFERENCED_PARAMETER(registry_path);

  UNICODE_STRING device_name;
  UNICODE_STRING dos_name;
  UNICODE_STRING device_sddl;
  RtlInitUnicodeString(&device_name, HARMONEY_DEVICE_NAME);
  RtlInitUnicodeString(&dos_name, HARMONEY_DOS_NAME);
  RtlInitUnicodeString(&device_sddl, L"D:P(A;;GA;;;SY)(A;;GA;;;BA)");

  NTSTATUS status = IoCreateDeviceSecure(
      driver, 0, &device_name, FILE_DEVICE_NETWORK, FILE_DEVICE_SECURE_OPEN,
      FALSE, &device_sddl, &HARMONEY_DEVICE_CLASS, &g_device);
  if (!NT_SUCCESS(status)) return status;

  status = IoCreateSymbolicLink(&dos_name, &device_name);
  if (!NT_SUCCESS(status)) {
    IoDeleteDevice(g_device);
    g_device = NULL;
    return status;
  }

  driver->MajorFunction[IRP_MJ_CREATE] = DispatchCreateClose;
  driver->MajorFunction[IRP_MJ_CLOSE] = DispatchCreateClose;
  driver->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DispatchDeviceControl;
  driver->DriverUnload = UnloadDriver;

  status = FwpsRedirectHandleCreate0(&HARMONEY_WFP_PROVIDER, 0,
                                     &g_redirect_handle);
  if (!NT_SUCCESS(status)) {
    UnloadDriver(driver);
    return status;
  }

  KeInitializeSpinLock(&g_udp_maps_lock);

  status = RegisterCallout(&HARMONEY_CONNECT_REDIRECT_V4, &g_callout_v4);
  if (NT_SUCCESS(status)) {
    status = RegisterCallout(&HARMONEY_CONNECT_REDIRECT_V6, &g_callout_v6);
  }
  if (!NT_SUCCESS(status)) {
    UnloadDriver(driver);
    return status;
  }
  return STATUS_SUCCESS;
}
