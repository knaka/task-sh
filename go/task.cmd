@echo off
setlocal enabledelayedexpansion

@REM BusyBox for Windows https://frippery.org/busybox/index.html
@REM rmyorston/busybox-w32: WIN32 native port of BusyBox. https://github.com/rmyorston/busybox-w32
@REM Index of /files/busybox https://frippery.org/files/busybox/?C=M;O=D
set ver=FRP-5398-g89ae34445

if "%1" == "update-me" (
  set "temp_dir=%TEMP%\tempdir_%RANDOM%"
  mkdir "!temp_dir!"
  curl.exe --fail --location --output !temp_dir!\%~nx0 https://raw.githubusercontent.com/knaka/scr/main/task.cmd || exit /b 1
  move /y !temp_dir!\%~nx0 %~f0
  rmdir /s /q !temp_dir!
  exit /b 0
)
set original_dir_path=%cd%
set script_dir_path=%~dp0
set script_name=%~n0
set env_file_path=!script_dir_path!\.env.sh.cmd
set sh_dir_path=!script_dir_path!
if exist !env_file_path! (
  call !env_file_path!
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
set bin_dir_path=%USERPROFILE%\.bin
if not exist !bin_dir_path! (
  mkdir "!bin_dir_path!"
)
set toolbox_cmd_path=!bin_dir_path!\!cmd_name!
if not exist !toolbox_cmd_path! (
  curl --location --output "!toolbox_cmd_path!" https://frippery.org/files/busybox/!cmd_name! 
)
!toolbox_cmd_path! sh !sh_dir_path!\!script_name!.sh %*
exit /b %ERRORLEVEL%
endlocal
