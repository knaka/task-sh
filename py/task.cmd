@REM id: 7403c4a
@echo off
setlocal enabledelayedexpansion
set script_dir_path=%~dp0
set script_name=%~n0
set sh_dir_path=!script_dir_path!
set env_file_path=!script_dir_path!\.env.sh.cmd
if exist !env_file_path! (
  call !env_file_path!
)
set toolbox_cmd_path=N/A
call !sh_dir_path!\toolbox.lib.cmd
!toolbox_cmd_path! sh !sh_dir_path!\!script_name!.sh %*
endlocal
