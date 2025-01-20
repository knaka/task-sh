@echo off
setlocal enabledelayedexpansion

set "required_min_major_ver=1"
set "required_min_minor_ver=23"

set "goroot_dir_path="

for /D %%d in (%USERPROFILE%\sdk\go* "C:\Program Files\Go") do (
  set "cmd=%%d\bin\go.exe"
  if exist "!cmd!" (
    for /F "usebackq tokens=*" %%v in (`"!cmd!" env GOVERSION`) do (
      set "version=%%v"
      set "major=!version:~2,1!"
      set "minor=!version:~4,2!"
      if !major! geq !required_min_major_ver! (
        if !minor! geq !required_min_minor_ver! (
          set "goroot_dir_path=%%d"
          goto :found_goroot
        )
      )
    )
  )
)

echo No appropriate Go installation found. >&2
exit 1

:found_goroot

