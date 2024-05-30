@echo off
echo Compose UP
powershell -NoProfile -ExecutionPolicy Unrestricted .\compose_up.ps1
echo Done
pause > nul
exit
