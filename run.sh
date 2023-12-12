#!/bin/bash

abs_script=$(readlink -f "$0")
abs_dir=$(dirname ${abs_script})

USE_DEVEL=""
USE_CONSOLE=""
USE_JUPYTER=""
WORK_DIR=${abs_dir}/userdir
JUPYTER_PORT="8888"
JUPYTER_DIR=/userdir
VERBOSE=""
CONTAINER_NAME="docker_irsl_system"
_ROS_SETUP=""
IMAGE_NAME=""
OPT=""
_PULL=""
_REPO="repo.irsl.eiiris.tut.ac.jp/"
MOUNT_OPTION=""
_DOCKER_OPT=""
_ROS_IP=
_ROS_MASTER_URI=

while [[ $# -gt 0 ]]; do
    case $1 in
        -D|--devel)
            USE_DEVEL="yes"
            shift
            ;;
        -p|--port)
            JUPYTER_PORT="$2"
            shift
            shift
            ;;
        -w|--workspace)
            WORK_DIR="$2"
            shift
            shift
            ;;
        -I|--image)
            IMAGE_NAME="$2"
            shift
            shift
            ;;
        -N|--name)
            CONTAINER_NAME="$2"
            shift
            shift
            ;;
        -G|--no-gpu)
            _NO_GPU="yes"
            shift
            ;;
        -U|--user)
            _USE_USER="yes"
            shift
            ;;
        -it)
            OPT="$OPT -it"
            shift
            ;;
        --mount)
            MOUNT_OPTION="${MOUNT_OPTION} $2"
            shift
            shift
            ;;
        --docker-option)
            _DOCKER_OPT="${_DOCKER_OPT} $2"
            shift
            shift
            ;;
        --ros-setup)
            _ROS_SETUP="$2"
            shift
            shift
            ;;
        -H|--hub)
            _REPO="irslrepo/"
            shift
            ;;
        --pull)
            _PULL="yes"
            shift
            ;;
#        -C|--console)
#            USE_CONSOLE="yes"
#            shift
#            ;;
        -j|--jupyter-dir)
            JUPYTER_DIR="$2"
            shift
            shift
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --help)
            #echo "run.sh [ -D | --devel ] [ -C | --console ] [ -J | --jupyter ] [ choreonoid(default) | assembler | jypyter | python ]"
            echo "run.sh [-D | --devel] [-p | --port port] [ choreonoid (-- args) | assembler | jypyter | choreonoid-console | python (-- args) | ipython (-- args) ]"
            exit 0
            ;;
        --ros-ip)
            _ROS_IP="$2"
            shift
            shift
            ;;
        --ros-master-uri)
            _ROS_MASTER_URI="$2"
            shift
            shift
            ;;
        --)
            shift
            break
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

## read arguments after '--'
while [[ $# -gt 0 ]]; do
    POSITIONAL_ARGS+=("$1") # save positional arg
    shift # past argument
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

### program
PROG=""
if [ $# -gt 0 ]; then
    PROG=$1
    shift
fi

### devel
dimage="${_REPO}irsl_system:noetic"
if [ -n "${USE_DEVEL}" ]; then
    dimage="${_REPO}irsl_system_devel:noetic"
fi
if [ -n "${IMAGE_NAME}" ]; then
    dimage="${IMAGE_NAME}"
fi

if [ -n "${_PULL}" ]; then
    docker pull ${dimage}
fi

### parse program
cur_var=""
if [ "${PROG}" == "choreonoid" ]; then
    cur_var="choreonoid $*"
elif [ "${PROG}" == "assembler" ]; then
    RADIR=/choreonoid_ws/install/share/choreonoid-2.0/robot_assembler
    cur_var="choreonoid $RADIR/layout/assembler.cnoid --assembler $RADIR/irsl/irsl_assembler_config.yaml --original-project $RADIR/layout/original.cnoid"
elif [ "${PROG}" == "jupyter" ]; then
    cur_var="jupyter lab --allow-root --no-browser --ip=0.0.0.0 --port=${JUPYTER_PORT} --notebook-dir=${JUPYTER_DIR} --FileCheckpoints.checkpoint_dir=/tmp --ServerApp.token=''"
elif [ "${PROG}" == "choreonoid-console" ]; then
    OPT="$OPT -it"
    cur_var="jupyter console --kernel=Choreonoid"
elif [ "${PROG}" == "python" ]; then
    OPT="$OPT -it"
    cur_var="python3 $*"
elif [ "${PROG}" == "ipython" ]; then
    OPT="-it"
    cur_var="ipython $*"
elif [ -n "${PROG}" ]; then
    cur_var="${PROG} $*"
fi

echo "image: $dimage"
echo "args: $cur_var"
DOCKER_CONTAINER=$CONTAINER_NAME \
DOCKER_ROS_SETUP=$_ROS_SETUP \
DOCKER_IMAGE=$dimage \
MOUNTED_DIR=$WORK_DIR \
OPT=$OPT \
NO_GPU=$_NO_GPU \
USE_USER=$_USE_USER \
ARG_ROS_IP=${_ROS_IP} \
ARG_ROS_MASTER_URI=${_ROS_MASTER_URI} \
DOCKER_OPTION="${MOUNT_OPTION} ${_DOCKER_OPT}" \
${abs_dir}/files/run_docker_main.sh \
${cur_var}
