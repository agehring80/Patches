@echo off

set WorkDir=%~dp0

:: FS-UAE
set ShortcutName1=FS-UAE.lnk
set TargetPath1=%~dp0FS-UAE\System\FS-UAE\Windows\x86-64\fs-uae.exe
set TargetParams1=--fullscreen -config "%~dp0FS-UAE\Configurations\AGS_FSUAE.fs-uae"
set IconLocation1=%TargetPath1%
set ShortcutLocation1=%WorkDir%%ShortcutName1%

:: FS-UAE_NoJoyStick (Cursor Keys needed... like in Worms and others)
set ShortcutName1a=FS-UAE_NoJoystick.lnk
set TargetParams1a=--fullscreen --joystick_port_1_mode=nothing -config "%~dp0FS-UAE\Configurations\AGS_FSUAE.fs-uae"
set ShortcutLocation1a=%WorkDir%%ShortcutName1a%

:: WinUAE
set ShortcutName2=WinUAE.lnk
set TargetPath2=%~dp0WinUAE\winuae64.exe
set TargetParams2=-f "%~dp0WinUAE\AGS_UAE.uae"
set IconLocation2=%TargetPath2%
set ShortcutLocation2=%WorkDir%%ShortcutName2%

if not exist "%TargetPath1%" (
    echo Error: Target executable "%TargetPath1%" not found.
    pause
    exit /b 1
)

if not exist "%TargetPath2%" (
    echo Error: Target executable "%TargetPath2%" not found.
    pause
    exit /b 1
)

powershell -NoProfile -Command ^
    "$ws = New-Object -ComObject WScript.Shell; $shortcut = $ws.CreateShortcut('%ShortcutLocation1%'); $shortcut.TargetPath = '%TargetPath1%'; $shortcut.Arguments = '%TargetParams1%'; $shortcut.WorkingDirectory = '%WorkDir%'; $shortcut.IconLocation = '%IconLocation1%'; $shortcut.Save();"

powershell -NoProfile -Command ^
    "$ws = New-Object -ComObject WScript.Shell; $shortcut = $ws.CreateShortcut('%ShortcutLocation1a%'); $shortcut.TargetPath = '%TargetPath1%'; $shortcut.Arguments = '%TargetParams1a%'; $shortcut.WorkingDirectory = '%WorkDir%'; $shortcut.IconLocation = '%IconLocation1%'; $shortcut.Save();"

powershell -NoProfile -Command ^
    "$ws = New-Object -ComObject WScript.Shell; $shortcut = $ws.CreateShortcut('%ShortcutLocation2%'); $shortcut.TargetPath = '%TargetPath2%'; $shortcut.Arguments = '%TargetParams2%'; $shortcut.WorkingDirectory = '%WorkDir%'; $shortcut.IconLocation = '%IconLocation2%'; $shortcut.Save();"

echo Shortcuts created:
echo %ShortcutLocation1%
echo %ShortcutLocation1a%
echo %ShortcutLocation2%
pause
