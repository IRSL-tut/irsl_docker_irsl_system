#!/bin/bash

## jupyter_process.sh target connection
_COM=$1
_CONNECTION=$2

_VGLRUN=

if [ -n "${VGL_DISPLAY}" ]; then
    _VGLRUN=vglrun
fi

#source /choreonoid_ws/install/setup.bash
source /irsl_entryrc

if [ "${_COM}" == "assembler" ]; then
    ${_VGLRUN} choreonoid --jupyter-connection ${_CONNECTION} \
               /choreonoid_ws/install/share/choreonoid-2.0/robot_assembler/layout/assembler.cnoid \
               --assembler /choreonoid_ws/install/share/choreonoid-2.0/robot_assembler/irsl/irsl_assembler_config.yaml \
               --original-project /choreonoid_ws/install/share/choreonoid-2.0/robot_assembler/layout/original.cnoid
elif [ "${_COM}" == "choreonoid" ]; then
    ${_VGLRUN} choreonoid --jupyter-connection ${_CONNECTION}
elif [ "${_COM}" == "roboprog" ]; then
    ${_VGLRUN} choreonoid --jupyter-connection ${_CONNECTION} \
               /choreonoid_ws/install/share/irsl_choreonoid/settings/only_scene.cnoid
fi
