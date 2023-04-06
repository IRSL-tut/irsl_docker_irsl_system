#!/bin/bash

set -e

## noetic or melodic
ROS_DISTRO_=${BUILD_ROS:-"noetic"}
UBUNTU_VER="22.04"
if [ ${ROS_DISTRO_} == "noetic" ]; then
    UBUNTU_VER="20.04"
elif [ ${ROS_DISTRO_} == "melodic" ]; then
    UBUNTU_VER="18.04"
fi

DOCKER_OPT='--progress plain'

REPO=repo.irsl.eiiris.tut.ac.jp/
XEUS_IMG=${REPO}xeus:${UBUNTU_VER}
BASE_IMG=${REPO}irsl_base:${ROS_DISTRO_}_nvidia
TARGET_IMG=${REPO}irsl_system:${ROS_DISTRO_}

docker build . ${DOCKER_OPT} -f Dockerfile.add_xeus     --build-arg BASE_IMAGE=${BASE_IMG} --build-arg BUILD_IMAGE=${XEUS_IMG} -t build_temp/build_system:0

docker build . ${DOCKER_OPT} -f Dockerfile.build_system --build-arg BASE_IMAGE=build_temp/build_system:0 --build-arg UBUNTU_VER=${UBUNTU_VER} -t ${TARGET_IMG}
