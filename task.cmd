@echo off
setlocal enabledelayedexpansion

@REM BusyBox for Windows https://frippery.org/busybox/index.html
@REM Release Notes https://frippery.org/busybox/release-notes/index.html
@REM Index of /files/busybox https://frippery.org/files/busybox/?C=M;O=D
set ver=FRP-5579-g5749feb35
if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  echo WARNING: Your environment is 32-bit. Not all features are supported. >&2
  set arch=32
) else if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set arch=64u
) else if "%PROCESSOR_ARCHITECTURE%" == "ARM64" (
  set arch=64a
) else (
  exit /b 1 
)
set cmd_name=busybox-w!arch!-!ver!.exe
set cache_dir_path=%USERPROFILE%\.cache\task-sh
if not exist !cache_dir_path! (
  mkdir "!cache_dir_path!"
)
set cmd_path=!cache_dir_path!\!cmd_name!
if not exist !cmd_path! (
  echo Downloading BusyBox for Windows. >&2
  curl.exe --fail --location --output "!cmd_path!" https://frippery.org/files/busybox/!cmd_name! || exit /b !ERRORLEVEL!
)

set "ARG0=%~f0"
set "ARG0BASE=%~n0"
set saved_pwd=%CD%
set initial_dir=%~dp0
@REM Remove trailing backslash from initial directory path if present
if "!initial_dir:~-1!"=="\" set "initial_dir=!initial_dir:~0,-1!"
@REM Change to the initial directory where the script is located
cd /d "!initial_dir!" || exit /b 1
set "PROJECT_DIR=%CD%"
set script_file_path=
:search_loop
if exist "!ARG0BASE!.sh" (
  set "script_file_path=%CD%\!ARG0BASE!.sh"
  goto found_script
)
if exist "tasks\!ARG0BASE!.sh" (
  set "script_file_path=%CD%\tasks\!ARG0BASE!.sh"
  goto found_script
)
set parent_dir=%CD%
cd ..
if "%CD%"=="!parent_dir!" (
  goto script_not_found
)
goto search_loop
:script_not_found
echo Cannot find script file for !ARG0! >&2
exit /b 1
:found_script
set "TASK_SH_DIR=%CD%"
cd /d "!saved_pwd!" || exit /b 1
set BB_GLOBBING=0
!cmd_path! sh "!script_file_path!" %* || exit /b !ERRORLEVEL!
endlocal
