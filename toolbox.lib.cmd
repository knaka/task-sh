setlocal enabledelayedexpansion

@REM Available commands // BusyBox - The Swiss Army Knife of Embedded Linux https://busybox.net/downloads/BusyBox.html
@REM BusyBox for Windows https://frippery.org/busybox/index.html
@REM rmyorston/busybox-w32: WIN32 native port of BusyBox. https://github.com/rmyorston/busybox-w32
@REM Index of /files/busybox https://frippery.org/files/busybox/?C=M;O=D
set ver=FRP-5398-g89ae34445

if "%1" == "update-me" (
  curl.exe --location --output %~f0 https://raw.githubusercontent.com/knaka/scr/main/toolbox.lib.cmd || exit /b 1
  exit /b 0
)
set bin_dir_path=%USERPROFILE%\.bin
if not exist !bin_dir_path! (
  mkdir "!bin_dir_path!"
)
set arch=%PROCESSOR_ARCHITECTURE%
if "%arch%" == "x86" (
  set archstr=32
) else if "%arch%" == "AMD64" (
  set archstr=64u
) else if "%arch%" == "ARM64" (
  set archstr=64a
) else (
  exit 1
)
set cmd_name=busybox-w!archstr!-!ver!.exe
set cmd_path=!bin_dir_path!\!cmd_name!
if not exist !cmd_path! (
  curl --location --output "!cmd_path!" https://frippery.org/files/busybox/!cmd_name! 
)
endlocal & (
  set toolbox_cmd_path=%cmd_path%
)
