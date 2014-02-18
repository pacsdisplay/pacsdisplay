@echo off
rem
rem Batch process for pacsDisplay installation.
rem

echo Starting to uninstall pacsDisplay...

echo Running Uninstall.exe
"C:\Program Files\HFHS\pacsDisplay\pacsDisplay-BIN\install\Uninstall.exe"

cd..
TIMEOUT 2

echo Removing remaining files
"C:\Program Files\HFHS\pacsDisplay_temp.bat"

echo Uninstall finished.

TIMEOUT 2
