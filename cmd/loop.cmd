@echo off

setlocal enabledelayedexpansion
@REM Do eternal loop with sleep 1 second
:loop
  @REM Do something
  echo Hello, world, Windows
  @REM Sleep 1 second
  @REM PowerShell batch script Timeout ERROR: Input redirection is not supported, exiting the process immediately - Stack Overflow https://stackoverflow.com/questions/74842935/powershell-batch-script-timeout-error-input-redirection-is-not-supported-exiti
  @REM timeout /t 1 /nobreak > nul
  @REM cmd /c start /min timeout.exe 1
  c:\windows\system32\ping.exe -n 2 127.0.0.1 > nul
  goto loop
endlocal
