# power-shell script for launching docker-compose

$scriptPath = $MyInvocation.MyCommand.Path
# echo $scriptPath

$scrdir = Split-Path -Parent $scriptPath
$compfile = $scrdir + "\docker-compose-win.yaml"
# echo $scrdir
# echo $compfile

docker compose -f $compfile up

pause
