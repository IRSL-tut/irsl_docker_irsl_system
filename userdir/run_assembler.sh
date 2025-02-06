#!/bin/bash

#source /choreonoid_ws/install/setup.bash
source /irsl_entryrc

CNOID_VER="$(echo $(find $(dirname $(which choreonoid))/../share -maxdepth 1 -name choreonoid-*) | sed -e 's@.*choreonoid-\(.*\)@\1@g')"
##
export RADIR="$(dirname $(which choreonoid))/../share/choreonoid-${CNOID_VER}/robot_assembler"

choreonoid $RADIR/layout/assembler.cnoid --assembler $RADIR/irsl/irsl_assembler_config.yaml --original-project $RADIR/layout/original.cnoid
