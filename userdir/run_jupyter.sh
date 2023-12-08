#!/bin/bash

JUPYTER_PORT=${1:-8888}
# echo "port: ${JUPYTER_PORT}"
_NOTE_DIR=
if [ -n "$1" ]; then
    _NOTE_DIR="--notebook-dir=$1"
fi

#source /choreonoid_ws/install/setup.bash
source /irsl_entryrc

jupyter lab --allow-root --no-browser --ip=0.0.0.0 --port=${JUPYTER_PORT} ${_NOTE_DIR} --FileCheckpoints.checkpoint_dir=/tmp --ServerApp.token=''
