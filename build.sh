#!/bin/bash

set -e

# ./build.sh [ target_image_name ]

## arguments as environment variables
# BUILD_ROS [ noetic ] or humble
# REPO [repo.irsl.eiiris.tut.ac.jp/]
# INPUT_IMAGE [ ${REPO}irsl_base:${BUILD_ROS}_nvidia ]
# NO_CACHE [ '' ]

## noetic or melodic
ROS_DISTRO_=${BUILD_ROS:-"noetic"}
UBUNTU_VER="22.04" ## humble
if [ ${ROS_DISTRO_} == "humble" ]; then
    UBUNTU_VER="22.04"
elif [ ${ROS_DISTRO_} == "noetic" ]; then
    UBUNTU_VER="20.04"
elif [ ${ROS_DISTRO_} == "melodic" ]; then
    UBUNTU_VER="18.04"
fi

DOCKER_OPT='--progress plain'

_REPO=${REPO:-repo.irsl.eiiris.tut.ac.jp/}
XEUS_IMG=${_REPO}xeus:${UBUNTU_VER}
BASE_IMG=${INPUT_IMAGE:-${_REPO}irsl_base:${ROS_DISTRO_}_nvidia}

DEFAULT_IMG=${_REPO}irsl_system:${ROS_DISTRO_}
TARGET_IMG=${1:-${DEFAULT_IMG}}

if [ -n ${NO_CACHE} ]; then
    DOCKER_OPT="--no-cache ${DOCKER_OPT}"
fi

DOCKER_FILE=Dockerfile.build_system
if [ -n "${BUILD_DEVEL}" ]; then
    echo "!!!! !!!! Build Devel !!!! !!!!"
    DOCKER_FILE=Dockerfile.build_system.devel
fi

echo "Build Image: ${TARGET_IMG}"

set -x

docker build . --progress=plain --pull -f Dockerfile.add_xeus  \
       --build-arg BASE_IMAGE=${BASE_IMG} --build-arg BUILD_IMAGE=${XEUS_IMG} --build-arg UBUNTU_VER=${UBUNTU_VER} \
       -t build_temp/build_system:0

docker build . ${DOCKER_OPT} -f ${DOCKER_FILE} --build-arg UBUNTU_VER=${UBUNTU_VER} \
       --build-arg BASE_IMAGE=build_temp/build_system:0 \
       -t ${TARGET_IMG}
