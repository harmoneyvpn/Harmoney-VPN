@echo off
REM Automated secure release Windows build script with full Flutter obfuscation
setlocal enabledelayedexpansion

set ROOT_DIR=%~dp0..
set APP_DIR=%ROOT_DIR%\apps\flutter
set SYMBOLS_DIR=%ROOT_DIR%\build_symbols

echo === Building Hardened Release Windows App for Harmoney ===
echo Working directory: %APP_DIR%
echo Symbols destination: %SYMBOLS_DIR%

if not exist "%SYMBOLS_DIR%" mkdir "%SYMBOLS_DIR%"
cd /d "%APP_DIR%"

call flutter pub get

REM Obfuscate all Dart AOT classes, functions, and metadata
call flutter build windows --release --obfuscate --split-debug-info="%SYMBOLS_DIR%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo >>> SUCCESS: Hardened Windows release built successfully!
    echo >>> Keep %SYMBOLS_DIR% private; do NOT distribute it with the application.
) else (
    echo.
    echo >>> ERROR: Build failed with exit code %ERRORLEVEL%
)

endlocal
