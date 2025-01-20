@echo off
setlocal enabledelayedexpansion

set "program_files_path=C:\Program Files"
echo daccba5: !program_files_path!
if exist "!program_files_path!" (
  echo It exists
) else (
  echo It does not exist
)
for %%i in ("C:\Program Files") do ( set "program_files_path=%%~si" )
echo 163e5db: !program_files_path!
if exist "!program_files_path!" (
  echo It exists
  dir /b "!program_files_path!"
) else (
  echo It does not exist
)

