#!/bin/bash

#source /choreonoid_ws/install/setup.bash
source /irsl_entryrc

##
export RADIR="$(dirname $(which choreonoid))/../share/choreonoid-2.0/robot_assembler"

choreonoid $RADIR/layout/assembler.cnoid --assembler $RADIR/irsl/irsl_assembler_config.yaml --original-project $RADIR/layout/original.cnoid
