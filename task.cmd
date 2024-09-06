@echo off
setlocal enabledelayedexpansion
if "%1" == "update-me" (
  set "temp_dir=%TEMP%\tempdir_%RANDOM%"
  mkdir "!temp_dir!"
  curl.exe --location --output !temp_dir!\%~f0 https://raw.githubusercontent.com/knaka/scr/main/task.cmd
  move /y !temp_dir!\%~f0 %~f0
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
set toolbox_cmd_path=undefined
cd /d !sh_dir_path!
set toolbox_file=toolbox.lib.cmd
:begin
  if exist !toolbox_file! (
    call !toolbox_file!
    goto :end
  )
  if %cd% == %cd:~0,3% (
    exit /b 1
  )
  cd ..
  goto :begin
:end
cd /d !original_dir_path!
!toolbox_cmd_path! sh !sh_dir_path!\!script_name!.sh %*
exit /b %ERRORLEVEL%
endlocal
