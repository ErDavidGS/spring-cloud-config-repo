@echo off
setlocal
set "ROOT=%~dp0.."
set "MAVEN_CMD=%ROOT%\.tools\apache-maven-3.9.9\bin\mvn.cmd"
if exist "%MAVEN_CMD%" goto run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\00-Obtener-Maven.ps1"
if errorlevel 1 exit /b 1
:run
call "%MAVEN_CMD%" %*
exit /b %ERRORLEVEL%