#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <fwpmu.h>
#include <iphlpapi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#pragma comment(lib, "fwpuclnt.lib")
#pragma comment(lib, "rpcrt4.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "iphlpapi.lib")

static const GUID HARMONEY_SUBLAYER = {0xd5686c0f,0x72f6,0x4af1,{0x9c,0x86,0x9f,0x84,0x49,0x53,0x32,0x20}};
static const GUID FILTER_ALLOW_V4 = {0xd3e99515,0x0554,0x4536,{0xac,0x2d,0x29,0x95,0x1c,0x5a,0xbc,0x55}};
static const GUID FILTER_ALLOW_V6 = {0x7ea0ccb4,0x3889,0x4f2b,{0x9d,0x98,0xe0,0x85,0xda,0x75,0xfc,0xeb}};
static const GUID HARMONEY_PERAPP_SUBLAYER = {0x6f583d45,0x0a8c,0x4e88,{0x9c,0x30,0x2c,0x20,0xa4,0x98,0x11,0x71}};
static const GUID HARMONEY_PERAPP_PROVIDER = {0x8955a328,0xa41e,0x4d3d,{0x93,0x23,0x6b,0x6c,0x2b,0x6a,0x74,0x18}};

typedef DWORD (WINAPI *FwpmConnectionPolicyAdd0Fn)(HANDLE, const FWPM_PROVIDER_CONTEXT3*, FWP_IP_VERSION, UINT64, UINT32, const FWPM_FILTER_CONDITION0*, PSECURITY_DESCRIPTOR);
typedef DWORD (WINAPI *FwpmConnectionPolicyDeleteByKey0Fn)(HANDLE, const GUID*);

static HMODULE load_wfp_api(void) {
    return LoadLibraryW(L"fwpuclnt.dll");
}

static DWORD check_native_perapp_api(void) {
    HMODULE module = load_wfp_api();
    if (!module) return GetLastError();
    BOOL available = GetProcAddress(module, "FwpmConnectionPolicyAdd0") != NULL &&
                     GetProcAddress(module, "FwpmConnectionPolicyDeleteByKey0") != NULL;
    FreeLibrary(module);
    return available ? ERROR_SUCCESS : ERROR_NOT_SUPPORTED;
}

static DWORD ensure_perapp_provider(HANDLE engine) {
    FWPM_PROVIDER0 provider;
    ZeroMemory(&provider, sizeof(provider));
    provider.providerKey = HARMONEY_PERAPP_PROVIDER;
    provider.displayData.name = L"Harmoney per-app routing";
    provider.displayData.description = L"Per-application physical-interface route policies";
    provider.flags = FWPM_PROVIDER_FLAG_PERSISTENT;
    DWORD rc = FwpmProviderAdd0(engine, &provider, NULL);
    return rc == FWP_E_ALREADY_EXISTS ? ERROR_SUCCESS : rc;
}

static GUID connection_policy_key(const FWP_BYTE_BLOB *app_id, FWP_IP_VERSION ip_version) {
    UINT64 a = 14695981039346656037ULL ^ (UINT64)ip_version;
    UINT64 b = 7809847782465536322ULL ^ ((UINT64)ip_version << 32);
    for (UINT32 i = 0; i < app_id->size; ++i) {
        a = (a ^ app_id->data[i]) * 1099511628211ULL;
        b = (b ^ (UINT8)(app_id->data[i] + i)) * 14029467366897019727ULL;
    }
    GUID key;
    key.Data1 = (UINT32)a;
    key.Data2 = (UINT16)(a >> 32);
    key.Data3 = (UINT16)((a >> 48) ^ (UINT16)(b >> 16));
    for (UINT32 i = 0; i < ARRAYSIZE(key.Data4); ++i)
        key.Data4[i] = (UINT8)(b >> (i * 8));
    return key;
}

static DWORD add_native_perapp_policy(HANDLE engine, const wchar_t *exe_path,
                                      UINT64 interface_luid, FWP_IP_VERSION ip_version) {
    HMODULE module = load_wfp_api();
    if (!module) return GetLastError();
    FwpmConnectionPolicyAdd0Fn add_policy = (FwpmConnectionPolicyAdd0Fn)GetProcAddress(module, "FwpmConnectionPolicyAdd0");
    if (!add_policy) { FreeLibrary(module); return ERROR_NOT_SUPPORTED; }

    FWP_BYTE_BLOB *app_id = NULL;
    DWORD rc = FwpmGetAppIdFromFileName0(exe_path, &app_id);
    if (rc != ERROR_SUCCESS) { FreeLibrary(module); return rc; }

    FWPM_NETWORK_CONNECTION_POLICY_SETTING0 setting;
    ZeroMemory(&setting, sizeof(setting));
    setting.type = FWP_NETWORK_CONNECTION_POLICY_NEXT_HOP_INTERFACE;
    setting.value.type = FWP_UINT64;
    setting.value.uint64 = &interface_luid;
    FWPM_NETWORK_CONNECTION_POLICY_SETTINGS0 settings;
    settings.numSettings = 1;
    settings.settings = &setting;

    FWPM_PROVIDER_CONTEXT3 context;
    ZeroMemory(&context, sizeof(context));
    context.providerContextKey = connection_policy_key(app_id, ip_version);
    context.displayData.name = L"Harmoney route selected application via physical uplink";
    context.flags = FWPM_PROVIDER_CONTEXT_FLAG_PERSISTENT;
    context.providerKey = (GUID *)&HARMONEY_PERAPP_PROVIDER;
    context.type = FWPM_NETWORK_CONNECTION_POLICY_CONTEXT;
    context.networkConnectionPolicy = &settings;

    FWPM_FILTER_CONDITION0 condition;
    ZeroMemory(&condition, sizeof(condition));
    condition.fieldKey = FWPM_CONDITION_ALE_APP_ID;
    condition.matchType = FWP_MATCH_EQUAL;
    condition.conditionValue.type = FWP_BYTE_BLOB_TYPE;
    condition.conditionValue.byteBlob = app_id;
    // The connection-policy API rejects zero and out-of-range priorities;
    // keep this app policy at a valid, deterministic non-zero weight.
    rc = add_policy(engine, &context, ip_version, 1, 1, &condition, NULL);
    FwpmFreeMemory0((void **)&app_id);
    FreeLibrary(module);
    return rc;
}

static DWORD ensure_perapp_sublayer(HANDLE engine) {
    FWPM_SUBLAYER0 s;
    ZeroMemory(&s, sizeof(s));
    s.subLayerKey = HARMONEY_PERAPP_SUBLAYER;
    s.displayData.name = L"Harmoney per-app bypass";
    s.displayData.description = L"Harmoney per-application physical-uplink redirect";
    s.flags = FWPM_SUBLAYER_FLAG_PERSISTENT;
    s.weight = 0x7100;
    DWORD rc = FwpmSubLayerAdd0(engine, &s, NULL);
    return rc == FWP_E_ALREADY_EXISTS ? ERROR_SUCCESS : rc;
}

static DWORD add_perapp_interface_allow(HANDLE engine, const wchar_t *exe_path,
                                        UINT32 ifindex, const GUID *layer) {
    FWP_BYTE_BLOB *app_id = NULL;
    DWORD rc = FwpmGetAppIdFromFileName0(exe_path, &app_id);
    if (rc != ERROR_SUCCESS) return rc;
    FWPM_FILTER_CONDITION0 conds[2];
    ZeroMemory(conds, sizeof(conds));
    conds[0].fieldKey = FWPM_CONDITION_ALE_APP_ID;
    conds[0].matchType = FWP_MATCH_EQUAL;
    conds[0].conditionValue.type = FWP_BYTE_BLOB_TYPE;
    conds[0].conditionValue.byteBlob = app_id;
    conds[1].fieldKey = FWPM_CONDITION_INTERFACE_INDEX;
    conds[1].matchType = FWP_MATCH_EQUAL;
    conds[1].conditionValue.type = FWP_UINT32;
    conds[1].conditionValue.uint32 = ifindex;

    FWPM_FILTER0 f;
    ZeroMemory(&f, sizeof(f));
    RPC_STATUS uuidStatus = UuidCreate(&f.filterKey);
    if (uuidStatus != RPC_S_OK && uuidStatus != RPC_S_UUID_LOCAL_ONLY) {
        FwpmFreeMemory0((void **)&app_id);
        return (DWORD)uuidStatus;
    }
    f.displayData.name = L"Harmoney allow selected application on physical uplink";
    f.layerKey = *layer;
    f.subLayerKey = HARMONEY_PERAPP_SUBLAYER;
    f.flags = FWPM_FILTER_FLAG_PERSISTENT;
    f.action.type = FWP_ACTION_PERMIT;
    f.weight.type = FWP_UINT8;
    // FWP_UINT8 filter weights are limited to the low 4-bit range.
    // The per-app sublayer itself is ordered above the kill-switch sublayer.
    f.weight.uint8 = 15;
    f.numFilterConditions = ARRAYSIZE(conds);
    f.filterCondition = conds;
    rc = FwpmFilterAdd0(engine, &f, NULL, NULL);
    FwpmFreeMemory0((void **)&app_id);
    return rc;
}

static DWORD add_native_perapp(HANDLE engine, const wchar_t *exe_path,
                               const wchar_t *ifindex_text) {
    wchar_t *end = NULL;
    unsigned long long parsed = _wcstoui64(ifindex_text, &end, 10);
    if (!end || *end != L'\0' || parsed == 0 || parsed > UINT32_MAX)
        return ERROR_INVALID_PARAMETER;
    if (check_native_perapp_api() != ERROR_SUCCESS) return ERROR_NOT_SUPPORTED;
    NET_LUID luid;
    DWORD rc = ConvertInterfaceIndexToLuid((NET_IFINDEX)parsed, &luid);
    if (rc != NO_ERROR) return rc;
    rc = ensure_perapp_provider(engine);
    if (rc == ERROR_SUCCESS) rc = ensure_perapp_sublayer(engine);
    if (rc == ERROR_SUCCESS)
        rc = add_perapp_interface_allow(engine, exe_path, (UINT32)parsed, &FWPM_LAYER_ALE_AUTH_CONNECT_V4);
    if (rc == ERROR_SUCCESS)
        rc = add_perapp_interface_allow(engine, exe_path, (UINT32)parsed, &FWPM_LAYER_ALE_AUTH_CONNECT_V6);
    if (rc == ERROR_SUCCESS)
        rc = add_native_perapp_policy(engine, exe_path, luid.Value, FWP_IP_VERSION_V4);
    if (rc == ERROR_SUCCESS)
        rc = add_native_perapp_policy(engine, exe_path, luid.Value, FWP_IP_VERSION_V6);
    return rc;
}

static DWORD clear_native_perapp_policies(HANDLE engine) {
    HMODULE module = load_wfp_api();
    if (!module) return GetLastError();
    FwpmConnectionPolicyDeleteByKey0Fn delete_policy =
        (FwpmConnectionPolicyDeleteByKey0Fn)GetProcAddress(module, "FwpmConnectionPolicyDeleteByKey0");
    if (!delete_policy) { FreeLibrary(module); return ERROR_NOT_SUPPORTED; }

    FWPM_PROVIDER_CONTEXT_ENUM_TEMPLATE0 template;
    ZeroMemory(&template, sizeof(template));
    template.providerKey = (GUID *)&HARMONEY_PERAPP_PROVIDER;
    template.providerContextType = FWPM_NETWORK_CONNECTION_POLICY_CONTEXT;
    HANDLE enumeration = NULL;
    DWORD rc = FwpmProviderContextCreateEnumHandle0(engine, &template, &enumeration);
    if (rc != ERROR_SUCCESS) { FreeLibrary(module); return rc; }
    for (;;) {
        FWPM_PROVIDER_CONTEXT3 **contexts = NULL;
        UINT32 count = 0;
        rc = FwpmProviderContextEnum3(engine, enumeration, 128, &contexts, &count);
        if (rc != ERROR_SUCCESS) {
            if (contexts) FwpmFreeMemory0((void **)&contexts);
            break;
        }
        for (UINT32 i = 0; i < count; ++i) {
            DWORD drc = delete_policy(engine, &contexts[i]->providerContextKey);
            if (drc != ERROR_SUCCESS && drc != FWP_E_PROVIDER_CONTEXT_NOT_FOUND &&
                drc != FWP_E_NOT_FOUND) rc = drc;
        }
        if (contexts) FwpmFreeMemory0((void **)&contexts);
        if (rc != ERROR_SUCCESS || count == 0) break;
    }
    FwpmProviderContextDestroyEnumHandle0(engine, enumeration);
    FreeLibrary(module);
    return rc;
}

static DWORD clear_native_perapp_path(HANDLE engine, const wchar_t *exe_path) {
    HMODULE module = load_wfp_api();
    if (!module) return GetLastError();
    FwpmConnectionPolicyDeleteByKey0Fn delete_policy =
        (FwpmConnectionPolicyDeleteByKey0Fn)GetProcAddress(module, "FwpmConnectionPolicyDeleteByKey0");
    if (!delete_policy) { FreeLibrary(module); return ERROR_NOT_SUPPORTED; }
    FWP_BYTE_BLOB *app_id = NULL;
    DWORD rc = FwpmGetAppIdFromFileName0(exe_path, &app_id);
    if (rc == ERROR_SUCCESS) {
        const FWP_IP_VERSION versions[] = { FWP_IP_VERSION_V4, FWP_IP_VERSION_V6 };
        for (UINT32 i = 0; i < ARRAYSIZE(versions); ++i) {
            GUID key = connection_policy_key(app_id, versions[i]);
            DWORD drc = delete_policy(engine, &key);
            if (drc != ERROR_SUCCESS && drc != FWP_E_PROVIDER_CONTEXT_NOT_FOUND &&
                drc != FWP_E_NOT_FOUND) rc = drc;
        }
        FwpmFreeMemory0((void **)&app_id);
    }
    FreeLibrary(module);
    return rc;
}

static DWORD clear_perapp(HANDLE engine, int path_count, wchar_t **paths) {
    DWORD policy_rc = clear_native_perapp_policies(engine);
    if (policy_rc != ERROR_SUCCESS && policy_rc != ERROR_NOT_SUPPORTED)
        return policy_rc;
    for (int i = 0; i < path_count; ++i) {
        DWORD path_rc = clear_native_perapp_path(engine, paths[i]);
        if (path_rc != ERROR_SUCCESS && path_rc != ERROR_NOT_SUPPORTED)
            return path_rc;
    }
    HANDLE enumeration = NULL;
    DWORD rc = FwpmFilterCreateEnumHandle0(engine, NULL, &enumeration);
    if (rc != ERROR_SUCCESS) return rc;
    GUID *keys = NULL;
    UINT32 keyCount = 0;
    for (;;) {
        FWPM_FILTER0 **filters = NULL;
        UINT32 count = 0;
        rc = FwpmFilterEnum0(engine, enumeration, 128, &filters, &count);
        if (rc != ERROR_SUCCESS) { if (filters) FwpmFreeMemory0((void **)&filters); break; }
        for (UINT32 i = 0; i < count; ++i) {
            if (!IsEqualGUID(&filters[i]->subLayerKey, &HARMONEY_PERAPP_SUBLAYER)) continue;
            GUID *grown = (GUID *)realloc(keys, (size_t)(keyCount + 1) * sizeof(GUID));
            if (!grown) { rc = ERROR_NOT_ENOUGH_MEMORY; break; }
            keys = grown;
            keys[keyCount++] = filters[i]->filterKey;
        }
        if (filters) FwpmFreeMemory0((void **)&filters);
        if (rc != ERROR_SUCCESS || count == 0) break;
    }
    FwpmFilterDestroyEnumHandle0(engine, enumeration);
    if (rc == ERROR_SUCCESS) {
        for (UINT32 i = 0; i < keyCount; ++i) {
            DWORD drc = FwpmFilterDeleteByKey0(engine, &keys[i]);
            if (drc != ERROR_SUCCESS && drc != FWP_E_FILTER_NOT_FOUND) rc = drc;
        }
    }
    free(keys);
    return rc;
}

static DWORD open_engine(HANDLE *engine) {
    return FwpmEngineOpen0(NULL, RPC_C_AUTHN_WINNT, NULL, NULL, engine);
}

static DWORD ensure_sublayer(HANDLE engine) {
    FWPM_SUBLAYER0 s;
    ZeroMemory(&s, sizeof(s));
    s.subLayerKey = HARMONEY_SUBLAYER;
    s.displayData.name = L"Harmoney VPN Kill Switch";
    s.displayData.description = L"Harmoney VPN WFP kill-switch policy";
    s.flags = FWPM_SUBLAYER_FLAG_PERSISTENT;
    s.weight = 0x7000;
    DWORD rc = FwpmSubLayerAdd0(engine, &s, NULL);
    if (rc == FWP_E_ALREADY_EXISTS) return ERROR_SUCCESS;
    return rc;
}

static DWORD add_block(HANDLE engine, const GUID *layer, UINT32 ifindex) {
    FWPM_FILTER_CONDITION0 cond;
    ZeroMemory(&cond, sizeof(cond));
    cond.fieldKey = FWPM_CONDITION_INTERFACE_INDEX;
    cond.matchType = FWP_MATCH_EQUAL;
    cond.conditionValue.type = FWP_UINT32;
    cond.conditionValue.uint32 = ifindex;

    FWPM_FILTER0 f;
    ZeroMemory(&f, sizeof(f));
    RPC_STATUS uuidStatus = UuidCreate(&f.filterKey);
    if (uuidStatus != RPC_S_OK && uuidStatus != RPC_S_UUID_LOCAL_ONLY) return (DWORD)uuidStatus;
    f.displayData.name = L"Harmoney block physical uplink";
    f.layerKey = *layer;
    f.subLayerKey = HARMONEY_SUBLAYER;
    f.flags = FWPM_FILTER_FLAG_PERSISTENT;
    f.action.type = FWP_ACTION_BLOCK;
    f.weight.type = FWP_UINT8;
    f.weight.uint8 = 10;
    f.numFilterConditions = 1;
    f.filterCondition = &cond;
    return FwpmFilterAdd0(engine, &f, NULL, NULL);
}

static DWORD add_allow_v4(HANDLE engine, UINT32 ifindex, const wchar_t *endpoint) {
    IN_ADDR addr;
    if (InetPtonW(AF_INET, endpoint, &addr) != 1) return ERROR_INVALID_PARAMETER;
    FWPM_FILTER_CONDITION0 conds[2];
    ZeroMemory(conds, sizeof(conds));
    conds[0].fieldKey = FWPM_CONDITION_INTERFACE_INDEX;
    conds[0].matchType = FWP_MATCH_EQUAL;
    conds[0].conditionValue.type = FWP_UINT32;
    conds[0].conditionValue.uint32 = ifindex;
    conds[1].fieldKey = FWPM_CONDITION_IP_REMOTE_ADDRESS;
    conds[1].matchType = FWP_MATCH_EQUAL;
    conds[1].conditionValue.type = FWP_UINT32;
    conds[1].conditionValue.uint32 = ntohl(addr.S_un.S_addr);

    FWPM_FILTER0 f;
    ZeroMemory(&f, sizeof(f));
    f.filterKey = FILTER_ALLOW_V4;
    f.displayData.name = L"Harmoney allow VPN endpoint IPv4";
    f.layerKey = FWPM_LAYER_ALE_AUTH_CONNECT_V4;
    f.subLayerKey = HARMONEY_SUBLAYER;
    f.flags = FWPM_FILTER_FLAG_PERSISTENT;
    f.action.type = FWP_ACTION_PERMIT;
    f.weight.type = FWP_UINT8;
    f.weight.uint8 = 15;
    f.numFilterConditions = 2;
    f.filterCondition = conds;
    return FwpmFilterAdd0(engine, &f, NULL, NULL);
}

static DWORD add_allow_v6(HANDLE engine, UINT32 ifindex, const wchar_t *endpoint) {
    IN6_ADDR addr;
    if (InetPtonW(AF_INET6, endpoint, &addr) != 1) return ERROR_INVALID_PARAMETER;
    FWP_BYTE_ARRAY16 bytes;
    CopyMemory(bytes.byteArray16, &addr, 16);
    FWPM_FILTER_CONDITION0 conds[2];
    ZeroMemory(conds, sizeof(conds));
    conds[0].fieldKey = FWPM_CONDITION_INTERFACE_INDEX;
    conds[0].matchType = FWP_MATCH_EQUAL;
    conds[0].conditionValue.type = FWP_UINT32;
    conds[0].conditionValue.uint32 = ifindex;
    conds[1].fieldKey = FWPM_CONDITION_IP_REMOTE_ADDRESS;
    conds[1].matchType = FWP_MATCH_EQUAL;
    conds[1].conditionValue.type = FWP_BYTE_ARRAY16_TYPE;
    conds[1].conditionValue.byteArray16 = &bytes;

    FWPM_FILTER0 f;
    ZeroMemory(&f, sizeof(f));
    f.filterKey = FILTER_ALLOW_V6;
    f.displayData.name = L"Harmoney allow VPN endpoint IPv6";
    f.layerKey = FWPM_LAYER_ALE_AUTH_CONNECT_V6;
    f.subLayerKey = HARMONEY_SUBLAYER;
    f.flags = FWPM_FILTER_FLAG_PERSISTENT;
    f.action.type = FWP_ACTION_PERMIT;
    f.weight.type = FWP_UINT8;
    f.weight.uint8 = 15;
    f.numFilterConditions = 2;
    f.filterCondition = conds;
    return FwpmFilterAdd0(engine, &f, NULL, NULL);
}

static DWORD add_allow_cidr_v4(HANDLE engine, UINT32 ifindex, const wchar_t *cidr) {
    wchar_t address[64];
    size_t length = wcslen(cidr);
    if (length == 0 || length >= _countof(address)) return ERROR_INVALID_PARAMETER;
    wcscpy_s(address, _countof(address), cidr);
    wchar_t *slash = wcschr(address, L'/');
    if (!slash) return ERROR_INVALID_PARAMETER;
    *slash++ = L'\0';
    wchar_t *end = NULL;
    unsigned long prefix = wcstoul(slash, &end, 10);
    if (!end || *end != L'\0' || prefix < 8 || prefix > 32) return ERROR_INVALID_PARAMETER;

    IN_ADDR addr;
    if (InetPtonW(AF_INET, address, &addr) != 1) return ERROR_INVALID_PARAMETER;
    FWP_V4_ADDR_AND_MASK remote;
    remote.addr = ntohl(addr.S_un.S_addr);
    remote.mask = prefix == 0 ? 0 : (UINT32)(0xFFFFFFFFu << (32 - prefix));

    FWPM_FILTER_CONDITION0 conds[2];
    ZeroMemory(conds, sizeof(conds));
    conds[0].fieldKey = FWPM_CONDITION_INTERFACE_INDEX;
    conds[0].matchType = FWP_MATCH_EQUAL;
    conds[0].conditionValue.type = FWP_UINT32;
    conds[0].conditionValue.uint32 = ifindex;
    conds[1].fieldKey = FWPM_CONDITION_IP_REMOTE_ADDRESS;
    conds[1].matchType = FWP_MATCH_EQUAL;
    conds[1].conditionValue.type = FWP_V4_ADDR_MASK;
    conds[1].conditionValue.v4AddrMask = &remote;

    FWPM_FILTER0 f;
    ZeroMemory(&f, sizeof(f));
    RPC_STATUS uuidStatus = UuidCreate(&f.filterKey);
    if (uuidStatus != RPC_S_OK && uuidStatus != RPC_S_UUID_LOCAL_ONLY) return (DWORD)uuidStatus;
    f.displayData.name = L"Harmoney allow country bypass IPv4";
    f.layerKey = FWPM_LAYER_ALE_AUTH_CONNECT_V4;
    f.subLayerKey = HARMONEY_SUBLAYER;
    f.flags = FWPM_FILTER_FLAG_PERSISTENT;
    f.action.type = FWP_ACTION_PERMIT;
    f.weight.type = FWP_UINT8;
    f.weight.uint8 = 20;
    f.numFilterConditions = 2;
    f.filterCondition = conds;
    return FwpmFilterAdd0(engine, &f, NULL, NULL);
}

static DWORD delete_sublayer_filters(HANDLE engine) {
    HANDLE enumeration = NULL;
    // NULL means enumerate all filters. A zeroed template can be interpreted
    // as an impossible match by WFP (FWP_E_NEVER_MATCH), preventing cleanup.
    DWORD rc = FwpmFilterCreateEnumHandle0(engine, NULL, &enumeration);
    if (rc != ERROR_SUCCESS) return rc;

    GUID *keys = NULL;
    UINT32 keyCount = 0;
    for (;;) {
        FWPM_FILTER0 **filters = NULL;
        UINT32 count = 0;
        rc = FwpmFilterEnum0(engine, enumeration, 128, &filters, &count);
        if (rc != ERROR_SUCCESS) {
            if (filters) FwpmFreeMemory0((void **)&filters);
            break;
        }
        for (UINT32 i = 0; i < count; ++i) {
            if (!IsEqualGUID(&filters[i]->subLayerKey, &HARMONEY_SUBLAYER)) continue;
            GUID *grown = (GUID *)realloc(keys, (size_t)(keyCount + 1) * sizeof(GUID));
            if (!grown) {
                rc = ERROR_NOT_ENOUGH_MEMORY;
                break;
            }
            keys = grown;
            keys[keyCount++] = filters[i]->filterKey;
        }
        if (filters) FwpmFreeMemory0((void **)&filters);
        if (rc != ERROR_SUCCESS || count == 0) break;
    }
    FwpmFilterDestroyEnumHandle0(engine, enumeration);
    if (rc == ERROR_SUCCESS) {
        for (UINT32 i = 0; i < keyCount; ++i) {
            DWORD deleteRc = FwpmFilterDeleteByKey0(engine, &keys[i]);
            if (deleteRc != ERROR_SUCCESS && deleteRc != FWP_E_FILTER_NOT_FOUND) rc = deleteRc;
        }
    }
    free(keys);
    return rc;
}

static DWORD disable_all(HANDLE engine) {
    DWORD rc = delete_sublayer_filters(engine);
    FwpmSubLayerDeleteByKey0(engine, &HARMONEY_SUBLAYER);
    return rc;
}

static DWORD enable_policy(HANDLE engine, UINT32 ifindex, const wchar_t *endpoint, int cidrCount, wchar_t **cidrs, int extraBlockCount, UINT32 *extraBlockIfindices) {
    DWORD rc = ensure_sublayer(engine);
    if (rc != ERROR_SUCCESS) return rc;
    disable_all(engine);
    rc = ensure_sublayer(engine);
    if (rc != ERROR_SUCCESS) return rc;

    IN_ADDR v4;
    IN6_ADDR v6;
    if (InetPtonW(AF_INET, endpoint, &v4) == 1) {
        rc = add_allow_v4(engine, ifindex, endpoint);
        if (rc != ERROR_SUCCESS) return rc;
    } else if (InetPtonW(AF_INET6, endpoint, &v6) == 1) {
        rc = add_allow_v6(engine, ifindex, endpoint);
        if (rc != ERROR_SUCCESS) return rc;
    } else {
        return ERROR_INVALID_PARAMETER;
    }

    for (int i = 0; i < cidrCount; ++i) {
        rc = add_allow_cidr_v4(engine, ifindex, cidrs[i]);
        if (rc != ERROR_SUCCESS) {
            disable_all(engine);
            return rc;
        }
    }

    for (int i = -1; i < extraBlockCount; ++i) {
        UINT32 blocked = i < 0 ? ifindex : extraBlockIfindices[i];
        if (blocked == 0 || (i >= 0 && blocked == ifindex)) continue;
        rc = add_block(engine, &FWPM_LAYER_ALE_AUTH_CONNECT_V4, blocked);
        if (rc != ERROR_SUCCESS) {
            disable_all(engine);
            return rc;
        }
        rc = add_block(engine, &FWPM_LAYER_ALE_AUTH_CONNECT_V6, blocked);
        if (rc != ERROR_SUCCESS) {
            disable_all(engine);
            return rc;
        }
    }
    return rc;
}

int wmain(int argc, wchar_t **argv) {
    if (argc < 2) {
        fwprintf(stderr, L"usage: wfp-helper enable <interface-index> <vpn-endpoint-ip> ... | disable | perapp-route <absolute-exe-path> <physical-interface-index> | perapp-clear | perapp-check\n");
        return 2;
    }
    if (_wcsicmp(argv[1], L"perapp-check") == 0 && argc == 2) {
        DWORD support = check_native_perapp_api();
        if (support != ERROR_SUCCESS) {
            fwprintf(stderr, L"Native per-app connection policy is unavailable (Windows error %lu / 0x%08lX).\n", support, support);
            return (int)support;
        }
        wprintf(L"supported\n");
        return 0;
    }
    HANDLE engine = NULL;
    DWORD rc = open_engine(&engine);
    if (rc != ERROR_SUCCESS) {
        fwprintf(stderr, L"FwpmEngineOpen0 failed: %lu\n", rc);
        return (int)rc;
    }
    if (_wcsicmp(argv[1], L"perapp-route") == 0 && argc == 4) {
        rc = add_native_perapp(engine, argv[2], argv[3]);
    } else if (_wcsicmp(argv[1], L"perapp-clear") == 0) {
        rc = clear_perapp(engine, argc - 2, argv + 2);
    } else if (_wcsicmp(argv[1], L"disable") == 0) {
        rc = disable_all(engine);
    } else if (_wcsicmp(argv[1], L"enable") == 0 && argc >= 4) {
        UINT32 ifindex = (UINT32)_wcstoui64(argv[2], NULL, 10);
        size_t extraCount = (size_t)(argc - 4);
        if (extraCount == 0) extraCount = 1;
        wchar_t **cidrs = (wchar_t **)calloc(extraCount, sizeof(wchar_t *));
        UINT32 *blockIfindices = (UINT32 *)calloc(extraCount, sizeof(UINT32));
        if (!ifindex || !cidrs || !blockIfindices) {
            rc = ERROR_NOT_ENOUGH_MEMORY;
        } else {
            int cidrCount = 0;
            int blockCount = 0;
            const wchar_t *prefix = L"--block-ifindex=";
            const size_t prefixLength = wcslen(prefix);
            for (int i = 4; i < argc; ++i) {
                if (_wcsnicmp(argv[i], prefix, prefixLength) == 0) {
                    UINT32 extra = (UINT32)_wcstoui64(argv[i] + prefixLength, NULL, 10);
                    if (!extra) { rc = ERROR_INVALID_PARAMETER; break; }
                    blockIfindices[blockCount++] = extra;
                } else {
                    cidrs[cidrCount++] = argv[i];
                }
            }
            if (rc == ERROR_SUCCESS) rc = enable_policy(engine, ifindex, argv[3], cidrCount, cidrs, blockCount, blockIfindices);
        }
        free(cidrs);
        free(blockIfindices);
    } else {
        rc = ERROR_INVALID_PARAMETER;
    }
    FwpmEngineClose0(engine);
    if (rc != ERROR_SUCCESS) {
        fwprintf(stderr, L"WFP operation failed: %lu (0x%08lX)\n", rc, rc);
        return (int)rc;
    }
    wprintf(L"ok\n");
    return 0;
}
