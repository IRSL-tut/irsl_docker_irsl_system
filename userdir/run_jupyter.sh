#!/bin/bash

JUPYTER_PORT=${1:-8888}
# echo "port: ${JUPYTER_PORT}"

source /choreonoid_ws/install/setup.bash

jupyter lab --allow-root --no-browser --ip=0.0.0.0 --port=${JUPYTER_PORT} --ServerApp.token=''
