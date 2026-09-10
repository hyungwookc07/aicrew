@echo off
rem teamradio56 update - double-click me.
rem Runs update.ps1 bypassing the PowerShell execution policy (this run only).
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update.ps1" %*
