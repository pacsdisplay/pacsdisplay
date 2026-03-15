rem
rem First two line needed to 'run as administrator' in current directory
rem

@setlocal enableextensions
@cd /d "%~dp0"

@echo off

rem
rem Batch process for pacsDisplay installation.
rem

echo Starting pacsDisplay Installation...

echo Running Install.exe
.\pacsDisplay-BIN\install\Install.exe

echo Installed finished...

TIMEOUT 2
