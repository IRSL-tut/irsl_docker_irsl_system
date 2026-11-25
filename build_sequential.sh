#!/bin/bash

# ./build_sequential.sh <files...>
# DOCKER_FILES
# INPUT_IMAGE :
# OUTPUT_IMAGE :
# BUILD_PREFIX :
# NO_CACHE :
# PULL :
# DOCKER_OPTION :

set -e

## required
_DOCKER_FILES=${DOCKER_FILES:-$@}
_INPUT_IMAGE=${INPUT_IMAGE:-""}

## optional
_PULL=${PULL:-""}
_CACHE=
_PID_="$$"
_OUTPUT_IMAGE=${OUTPUT_IMAGE:-"build_output"}
_BUILD_PREFIX=${BUILD_PREFIX:-"temp/build_image${_PID_}"}

if [ -n "$NO_CACHE" ]; then
    _CACHE='--no-cache'
fi

_DOCKER_OPT="--progress plain ${DOCKER_OPTION}"

# echo ${_DOCKER_FILES}
# for fname in ${_DOCKER_FILES}; do
#     set -x
#     echo ${fname}
#     set +x
# done

if [ -z "${_INPUT_IMAGE}" ]; then
    echo "Please set INPUT_IMAGE environment-variable"
    exit 0
fi

if [ -n "${_PULL}" ]; then
    set +e
    set -x
    for i in {1..10}
    do
        docker pull ${_INPUT_IMAGE}
        if [ $? -eq 0 ]; then
            break;
        fi
    done
    set +x
    set -e
fi

_CNTR=0
_NEXT_IMAGE=${_BUILD_PREFIX}:${_CNTR}

_LOG_FILE_="/tmp/build_log${_PID_}.txt"
touch ${_LOG_FILE_}

postprocess() {
    trap - EXIT
    echo "############ postprocess $? ############"
    cat ${_LOG_FILE_}
    exit $?
}

trap postprocess EXIT INT TERM

echo "############ start ############"
echo "##  input: ${_INPUT_IMAGE}"
echo "## output: ${_OUTPUT_IMAGE}"
echo "## option: ${_DOCKER_OPT}"
echo "##    log: ${_LOG_FILE_}"
echo "##  files: ${_DOCKER_FILES}"

for fname in ${_DOCKER_FILES}; do
    echo ">>>> build: ${_NEXT_IMAGE}"
    echo ">>>> build: ${_NEXT_IMAGE}" >> ${_LOG_FILE_}
    set -x
    docker build . ${_CACHE} ${_DOCKER_OPT} -f ${fname} \
           --build-arg BASE_IMAGE=${_INPUT_IMAGE} \
           -t ${_NEXT_IMAGE} &>> ${_LOG_FILE_}
    set +x
    _INPUT_IMAGE=${_NEXT_IMAGE}
    _CNTR=$(expr ${_CNTR} + 1)
    _NEXT_IMAGE=${_BUILD_PREFIX}:${_CNTR}
    _CACHE=
done
echo ">>>> tag" >> ${_LOG_FILE_}
echo ">>>> docker tag ${_INPUT_IMAGE} ${_OUTPUT_IMAGE} &>> ${_LOG_FILE_}"
set -x
docker tag ${_INPUT_IMAGE} ${_OUTPUT_IMAGE} &>> ${_LOG_FILE_}
set +x
echo ">>>> DONE" >> ${_LOG_FILE_}
