@echo off
title Microsoft Edge Remover
setlocal EnableExtensions

:: ==========================================================
::  [1] RUN AS ADMINISTRATOR
:: ==========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges required - restarting elevated...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "PF86=%ProgramFiles(x86)%"
set "PF=%ProgramFiles%"
set "PD=%ProgramData%"

cls
echo ==========================================================
echo   MICROSOFT EDGE REMOVER
echo ==========================================================
echo   This script will completely remove Microsoft Edge:
echo    - kill all Edge processes and services
echo    - run the official uninstaller
echo    - delete files, shortcuts and registry entries
echo.
echo   WARNING: Edge stores user data (passwords, bookmarks,
echo   history). It will be permanently deleted!
echo   WebView2 Runtime is NOT removed (other programs depend on it).
echo ==========================================================
echo.
choice /c YN /n /m "Continue? [Y]es / [N]o: "
if errorlevel 2 exit /b

:: ==========================================================
::  [2] KILL ALL EDGE PROCESSES + SERVICES
:: ==========================================================
echo.
echo [1/7] Killing Edge processes...
for %%P in (msedge.exe msedgewebview2.exe MicrosoftEdgeUpdate.exe MicrosoftEdgeUpdateBroker.exe MicrosoftEdgeUpdateCore.exe MicrosoftEdgeUpdateOnDemand.exe MicrosoftEdgeUpdateComRegisterShell64.exe MicrosoftEdgeCP.exe MicrosoftEdgeSH.exe MicrosoftEdge.exe identity_helper.exe msedgeupdate.exe elevation_service.exe pwahelper.exe notification_helper.exe cookie_exporter.exe) do (
    taskkill /f /t /im %%P >nul 2>&1
)

echo [2/7] Stopping and deleting Edge services...
for %%S in (edgeupdate edgeupdatem MicrosoftEdgeElevationService) do (
    sc stop %%S >nul 2>&1
    sc delete %%S >nul 2>&1
)

echo       Deleting scheduled tasks...
for /f "tokens=1 delims=," %%T in ('schtasks /query /fo csv /nh 2^>nul ^| findstr /i "MicrosoftEdgeUpdate"') do (
    schtasks /delete /tn %%~T /f >nul 2>&1
)

:: ==========================================================
::  [3] OFFICIAL UNINSTALLER
:: ==========================================================
echo [3/7] Running Edge uninstaller...
for /d %%V in ("%PF86%\Microsoft\Edge\Application\*") do (
    if exist "%%V\Installer\setup.exe" (
        "%%V\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall >nul 2>&1
    )
)
for /d %%V in ("%PF%\Microsoft\Edge\Application\*") do (
    if exist "%%V\Installer\setup.exe" (
        "%%V\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall >nul 2>&1
    )
)
timeout /t 3 /nobreak >nul
taskkill /f /t /im msedge.exe >nul 2>&1

:: ==========================================================
::  [4] DELETE FILES / FOLDERS
:: ==========================================================
echo [4/7] Deleting files and folders...
call :nuke "%PF86%\Microsoft\Edge"
call :nuke "%PF86%\Microsoft\EdgeCore"
call :nuke "%PF86%\Microsoft\EdgeUpdate"
call :nuke "%PF86%\Microsoft\Temp"
call :nuke "%PF%\Microsoft\Edge"
call :nuke "%PD%\Microsoft\EdgeUpdate"
call :nuke "%PD%\Microsoft\Edge"

for /d %%U in ("%SystemDrive%\Users\*") do (
    call :nuke "%%U\AppData\Local\Microsoft\Edge"
    call :nuke "%%U\AppData\Local\Microsoft\EdgeUpdate"
    call :nuke "%%U\AppData\Local\Microsoft\Edge Dev"
    call :nuke "%%U\AppData\Local\Microsoft\Edge Beta"
    call :nuke "%%U\AppData\Local\Microsoft\Edge SxS"
    call :nuke "%%U\AppData\Roaming\Microsoft\Edge"
)

:: ==========================================================
::  [5] SHORTCUTS
:: ==========================================================
echo [5/7] Deleting shortcuts...
del /f /q "%PUBLIC%\Desktop\Microsoft Edge.lnk" >nul 2>&1
del /f /q "%PD%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" >nul 2>&1
for /d %%U in ("%SystemDrive%\Users\*") do (
    del /f /q "%%U\Desktop\Microsoft Edge.lnk" >nul 2>&1
    del /f /q "%%U\OneDrive\Desktop\Microsoft Edge.lnk" >nul 2>&1
    del /f /q "%%U\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" >nul 2>&1
    del /f /q "%%U\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk" >nul 2>&1
    del /f /q "%%U\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk" >nul 2>&1
    del /f /q "%%U\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu\Microsoft Edge.lnk" >nul 2>&1
)

:: ==========================================================
::  [6] REGISTRY (with backup of main keys)
:: ==========================================================
echo [6/7] Cleaning registry (backup: edge_backup_*.reg)...
reg export "HKLM\SOFTWARE\Microsoft\Edge" "%~dp0edge_backup_hklm.reg" /y >nul 2>&1
reg export "HKLM\SOFTWARE\WOW6432Node\Microsoft\Edge" "%~dp0edge_backup_hklm_wow.reg" /y >nul 2>&1
reg export "HKCU\Software\Microsoft\Edge" "%~dp0edge_backup_hkcu.reg" /y >nul 2>&1

for %%K in (
    "HKLM\SOFTWARE\Microsoft\Edge"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Edge"
    "HKLM\SOFTWARE\Microsoft\EdgeUpdate"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate"
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update"
    "HKLM\SOFTWARE\Clients\StartMenuInternet\Microsoft Edge"
    "HKLM\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\Microsoft Edge"
    "HKLM\SOFTWARE\Policies\Microsoft\Edge"
    "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate"
    "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem"
    "HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService"
    "HKCU\Software\Microsoft\Edge"
    "HKCU\Software\Microsoft\EdgeUpdate"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
    "HKCU\Software\Policies\Microsoft\Edge"
    "HKCR\MSEdgeHTM"
    "HKCR\MSEdgePDF"
    "HKCR\MSEdgeMHT"
    "HKCR\Applications\msedge.exe"
) do (
    reg delete %%K /f >nul 2>&1
)

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /f >nul 2>&1

:: ==========================================================
::  [7] OPTIONAL: BLOCK REINSTALLATION
:: ==========================================================
echo.
choice /c YN /n /m "[7/7] Block Edge reinstallation via Windows Update? [Y/N]: "
if errorlevel 2 goto :done
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v InstallDefault /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v UpdateDefault /t REG_DWORD /d 0 /f >nul 2>&1
echo       Blocked.

:done
echo.
echo ==========================================================
echo   DONE. A system restart is recommended.
echo ==========================================================
pause
exit /b

:: ==========================================================
::  SUBROUTINE: take ownership + force delete a folder
:: ==========================================================
:nuke
if not exist "%~1" exit /b
takeown /f "%~1" /r /d y >nul 2>&1
icacls "%~1" /grant *S-1-5-32-544:F /t /c /q >nul 2>&1
rd /s /q "%~1" >nul 2>&1
exit /b
