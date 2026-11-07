#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/method_channel.h>
#include <flutter/flutter_view_controller.h>

#include <memory>
#include <map>
#include <string>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project,
                         bool show_window = true,
                         bool tray_enabled = true);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;
  bool show_window_;
  bool tray_enabled_;
  bool visibility_initialized_ = false;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> tray_channel_;
  NOTIFYICONDATA tray_icon_{};
  bool tray_connected_ = false;
  bool tray_transitioning_ = false;
  bool tray_auto_connect_ = false;
  bool tray_launch_on_startup_ = false;
  bool tray_start_minimized_ = false;
  bool tray_exiting_ = false;
  std::wstring tray_server_ = L"Automatic";
  std::wstring tray_status_text_ = L"Disconnected";
  std::map<std::string, std::wstring> tray_labels_;

  void AddTrayIcon();
  void RemoveTrayIcon();
  void ShowTrayMenu();
  void UpdateTrayTooltip();
  void InvokeTrayAction(const char* method);
  std::wstring TrayLabel(const std::string& key, const wchar_t* fallback) const;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
