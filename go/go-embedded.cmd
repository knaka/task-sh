@echo off
setlocal enabledelayedexpansion

set "exit_code=1"

# All releases - The Go Programming Language https://go.dev/dl/
set "cmd=go"
set "ver=1.23.0"

:unique_loop
set "temp_dir_path=%TEMP%\!name!-%RANDOM%"
if exist "!temp_dir_path!" goto unique_loop
md "!temp_dir_path!" || goto :exit

where !cmd!
if %ERRORLEVEL%==0 (
  set "cmd_path=go"
  goto found_cmd
)
set "dirs=%USERPROFILE%\go\go%ver%\bin:%USERPROFILE%\sdk\go%ver%\bin;\Program Files\Go\bin"
for %%d in ("%dirs:;=" "%") do (
	for /d %%g in (%%d) do (
		if exist "%%g\%cmd%.exe" (
			set "cmd_path=%%G\%cmd%.exe"
			goto found_cmd
		)
	)
)
set "goos=windows"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set "goarch=amd64"
) else if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
	set "goarch=amd64"
) else (
	goto :exit
)
set "sdk_dir_path=%USERPROFILE%\sdk"
if not exist "!sdk_dir_path!" (
	mkdir "!sdk_dir_path!" || goto :exit
)
set "zip_path=!temp_dir_path!\temp.zip"
curl.exe --fail --location -o "!zip_path!" "https://go.dev/dl/go%ver%.%goos%-%goarch%.zip" || goto :exit
cd "!sdk_dir_path!" || goto :exit
unzip.exe -q "!zip_path!" || goto :exit
move.exe /y "!sdk_dir_path!\go" "!sdk_dir_path!\go%ver%" || goto :exit
set "cmd_path=!sdk_dir_path!\go%ver%\bin\%cmd%.exe"

:found_cmd
for /f "usebackq tokens=1 delims=:" %%i in (`findstr /n /b :embed_53c8fd5 "%~f0"`) do set n=%%i
set "name=go-embedded"
set "tempfile=!temp_dir_path!\!name!.go"
more +%n% "%~f0" > "!tempfile!"
!cmd_path! build -o %USERPROFILE%\go\bin\!name!.exe "!tempfile!" || goto :exit
del /q "!temp_dir_path!"
set "exit_code=0"
goto :exit

:exit
if exist "!temp_dir_path!" (
	del /q "!temp_dir_path!"
)
exit /b !exit_code!

endlocal

:embed_53c8fd5
package main

func main() {
    println("Hello, World!")
}
