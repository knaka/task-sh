@echo off

dir c:\not_exists || exit /b !ERRORLEVEL!
