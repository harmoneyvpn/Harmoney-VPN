#include "flutter_window.h"

#include <shellapi.h>
#include <windows.h>
#include <flutter/standard_method_codec.h>

#include <string>
#include <map>
#include <optional>
#include <variant>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

namespace {
constexpr UINT kTrayMessage = WM_APP + 41;
constexpr UINT kTrayOpen = 41001;
constexpr UINT kTrayToggle = 41002;
constexpr UINT kTrayServers = 41003;
constexpr UINT kTrayExit = 41004;
constexpr UINT kTraySettings = 41005;
constexpr UINT kTrayLogs = 41006;
constexpr UINT kTrayAutoConnect = 41007;
constexpr UINT kTrayLaunchOnStartup = 41008;
constexpr UINT kTrayStartMinimized = 41009;
constexpr UINT kTrayExitFallbackTimer = 41010;
constexpr UINT kTrayQuitNow = WM_APP + 42;
constexpr UINT kTrayIconId = 1;

std::wstring Utf8ToWide(const std::string& value) {
  if (value.empty()) return {};
  const int size = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
      value.data(), static_cast<int>(value.size()), nullptr, 0);
  if (size <= 0) return {};
  std::wstring result(static_cast<size_t>(size), L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), result.data(), size);
  return result;
}

std::string ReadString(const flutter::EncodableMap& values,
                       const char* key) {
  const auto it = values.find(flutter::EncodableValue(key));
  if (it == values.end()) return {};
  const auto* value = std::get_if<std::string>(&it->second);
  return value == nullptr ? std::string{} : *value;
}

bool ReadBool(const flutter::EncodableMap& values, const char* key) {
  const auto it = values.find(flutter::EncodableValue(key));
  if (it == values.end()) return false;
  const auto* value = std::get_if<bool>(&it->second);
  return value != nullptr && *value;
}
}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project,
                             bool show_window, bool tray_enabled)
    : project_(project), show_window_(show_window), tray_enabled_(tray_enabled) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  tray_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "io.harmoney.client/windows_tray",
      &flutter::StandardMethodCodec::GetInstance());
  tray_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "updateState") {
          const auto* values = std::get_if<flutter::EncodableMap>(call.arguments());
          if (values != nullptr) {
            const std::string status = ReadString(*values, "status");
            tray_connected_ = status == "connected";
            tray_transitioning_ = status == "connecting" || status == "disconnecting";
            tray_auto_connect_ = ReadBool(*values, "autoConnect");
            tray_launch_on_startup_ = ReadBool(*values, "launchOnStartup");
            tray_start_minimized_ = ReadBool(*values, "startMinimized");
            const char* label_key = tray_connected_ ? "connected" :
                tray_transitioning_ ? (status == "disconnecting" ? "disconnecting" : "connecting") :
                status == "error" ? "error" : "disconnected";
            const wchar_t* fallback_status = tray_connected_ ? L"Connected" :
                tray_transitioning_ ? (status == "disconnecting" ? L"Disconnecting" : L"Connecting") :
                status == "error" ? L"Error" : L"Disconnected";
            tray_status_text_ = Utf8ToWide(ReadString(*values, label_key));
            if (tray_status_text_.empty()) tray_status_text_ = fallback_status;
            const std::string name = ReadString(*values, "server");
            tray_server_ = Utf8ToWide(name);
            const auto labels_it = values->find(flutter::EncodableValue("labels"));
            if (labels_it != values->end()) {
              const auto* raw_labels = std::get_if<flutter::EncodableMap>(&labels_it->second);
              if (raw_labels != nullptr) {
              tray_labels_.clear();
              for (const auto& entry : *raw_labels) {
                const auto* key = std::get_if<std::string>(&entry.first);
                const auto* value = std::get_if<std::string>(&entry.second);
                if (key != nullptr && value != nullptr) {
                  tray_labels_[*key] = Utf8ToWide(*value);
                }
              }
              }
            }
            UpdateTrayTooltip();
            if (!visibility_initialized_ && tray_enabled_) {
              visibility_initialized_ = true;
              show_window_ = !tray_start_minimized_;
              if (tray_start_minimized_) ShowWindow(GetHandle(), SW_HIDE);
            }
          }
          result->Success();
          return;
        }
        if (call.method_name() == "quitApplication") {
          KillTimer(GetHandle(), kTrayExitFallbackTimer);
          tray_exiting_ = true;
          RemoveTrayIcon();
          result->Success();
          PostMessage(GetHandle(), kTrayQuitNow, 0, 0);
          return;
        }
        result->NotImplemented();
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  if (tray_enabled_) AddTrayIcon();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    if (show_window_) this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  RemoveTrayIcon();
  tray_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case kTrayQuitNow:
      tray_exiting_ = true;
      DestroyWindow(hwnd);
      return 0;
    case WM_TIMER:
      if (wparam == kTrayExitFallbackTimer) {
        KillTimer(hwnd, kTrayExitFallbackTimer);
        tray_exiting_ = true;
        RemoveTrayIcon();
        DestroyWindow(hwnd);
        return 0;
      }
      break;
    case WM_CLOSE:
      if (tray_enabled_ && !tray_exiting_) {
        ShowWindow(hwnd, SW_HIDE);
        return 0;
      }
      break;
    case kTrayMessage:
      if (HIWORD(lparam) == NIN_SELECT || HIWORD(lparam) == NIN_KEYSELECT) {
        Show();
        SetForegroundWindow(hwnd);
        InvokeTrayAction("openApp");
      } else if (HIWORD(lparam) == WM_CONTEXTMENU) {
        ShowTrayMenu();
      }
      return 0;
    case WM_COMMAND:
      switch (LOWORD(wparam)) {
        case kTrayOpen:
          Show();
          SetForegroundWindow(hwnd);
          InvokeTrayAction("openApp");
          return 0;
        case kTrayToggle:
          InvokeTrayAction("toggleConnection");
          return 0;
        case kTrayServers:
          Show();
          SetForegroundWindow(hwnd);
          InvokeTrayAction("openServers");
          return 0;
        case kTraySettings:
          Show();
          SetForegroundWindow(hwnd);
          InvokeTrayAction("openSettings");
          return 0;
        case kTrayLogs:
          Show();
          SetForegroundWindow(hwnd);
          InvokeTrayAction("openLogs");
          return 0;
        case kTrayAutoConnect:
          InvokeTrayAction("toggleAutoConnect");
          return 0;
        case kTrayLaunchOnStartup:
          InvokeTrayAction("toggleLaunchOnStartup");
          return 0;
        case kTrayStartMinimized:
          InvokeTrayAction("toggleStartMinimized");
          return 0;
        case kTrayExit:
          SetTimer(hwnd, kTrayExitFallbackTimer, 12000, nullptr);
          InvokeTrayAction("quitApplication");
          return 0;
      }
      break;
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::AddTrayIcon() {
  tray_icon_ = {};
  tray_icon_.cbSize = sizeof(NOTIFYICONDATA);
  tray_icon_.hWnd = GetHandle();
  tray_icon_.uID = kTrayIconId;
  tray_icon_.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  tray_icon_.uCallbackMessage = kTrayMessage;
  tray_icon_.hIcon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  wcscpy_s(tray_icon_.szTip, L"Harmoney VPN");
  Shell_NotifyIcon(NIM_ADD, &tray_icon_);
  tray_icon_.uVersion = NOTIFYICON_VERSION_4;
  Shell_NotifyIcon(NIM_SETVERSION, &tray_icon_);
}

void FlutterWindow::RemoveTrayIcon() {
  if (tray_icon_.hWnd != nullptr) Shell_NotifyIcon(NIM_DELETE, &tray_icon_);
  tray_icon_.hWnd = nullptr;
}

void FlutterWindow::UpdateTrayTooltip() {
  if (tray_icon_.hWnd == nullptr) return;
  const std::wstring tooltip = TrayLabel("appName", L"Harmoney VPN") + L" - " +
      tray_status_text_ + L" - " + tray_server_;
  wcsncpy_s(tray_icon_.szTip, tooltip.c_str(), _TRUNCATE);
  tray_icon_.uFlags = NIF_TIP;
  Shell_NotifyIcon(NIM_MODIFY, &tray_icon_);
}

void FlutterWindow::ShowTrayMenu() {
  HMENU menu = CreatePopupMenu();
  if (menu == nullptr) return;
  AppendMenuW(menu, MF_STRING, kTrayOpen,
              TrayLabel("openApplication", L"Open Application").c_str());
  const char* action_key = tray_connected_ ? "disconnect" :
      tray_transitioning_ ? "cancelConnection" : "connect";
  const wchar_t* action_fallback = tray_connected_ ? L"Disconnect" :
      tray_transitioning_ ? L"Cancel connection" : L"Connect";
  AppendMenuW(menu, MF_STRING, kTrayToggle,
              TrayLabel(action_key, action_fallback).c_str());
  AppendMenuW(menu, MF_STRING, kTrayServers,
              TrayLabel("chooseServer", L"Choose server…").c_str());
  AppendMenuW(menu, MF_STRING, kTraySettings,
              TrayLabel("preferences", L"Preferences / Settings").c_str());
  AppendMenuW(menu, MF_STRING, kTrayLogs,
              TrayLabel("logs", L"Logs").c_str());
  AppendMenu(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING | (tray_auto_connect_ ? MF_CHECKED : MF_UNCHECKED),
              kTrayAutoConnect, TrayLabel("autoConnect", L"Auto-connect").c_str());
  AppendMenuW(menu, MF_STRING | (tray_launch_on_startup_ ? MF_CHECKED : MF_UNCHECKED),
              kTrayLaunchOnStartup,
              TrayLabel("launchOnStartup", L"Launch on startup").c_str());
  AppendMenuW(menu, MF_STRING | (tray_start_minimized_ ? MF_CHECKED : MF_UNCHECKED),
              kTrayStartMinimized,
              TrayLabel("startMinimized", L"Start minimized").c_str());
  AppendMenu(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING, kTrayExit, TrayLabel("exit", L"Exit").c_str());
  POINT point{};
  GetCursorPos(&point);
  SetForegroundWindow(GetHandle());
  TrackPopupMenu(menu, TPM_RIGHTBUTTON | TPM_BOTTOMALIGN | TPM_LEFTALIGN,
                 point.x, point.y, 0, GetHandle(), nullptr);
  PostMessage(GetHandle(), WM_NULL, 0, 0);
  DestroyMenu(menu);
}

std::wstring FlutterWindow::TrayLabel(const std::string& key,
                                      const wchar_t* fallback) const {
  const auto it = tray_labels_.find(key);
  return it == tray_labels_.end() || it->second.empty() ? fallback : it->second;
}

void FlutterWindow::InvokeTrayAction(const char* method) {
  if (tray_channel_ == nullptr) return;
  tray_channel_->InvokeMethod(method,
      std::make_unique<flutter::EncodableValue>());
}
