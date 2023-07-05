#!/bin/bash

abs_script=$(readlink -f "$0")
abs_dir=$(dirname ${abs_script})

USE_DEVEL=""
USE_CONSOLE=""
USE_JUPYTER=""
WORK_DIR=${abs_dir}/userdir
JUPYTER_PORT="8888"
VERBOSE=""
CONTAINER_NAME="docker_irsl_system"

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
#        -C|--console)
#            USE_CONSOLE="yes"
#            shift
#            ;;
#        -J|--jupyter)
#            USE_JUPYTER="yes"
#            shift
#            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --help)
            #echo "run.sh [ -D | --devel ] [ -C | --console ] [ -J | --jupyter ] [ choreonoid(default) | assembler | jypyter | python ]"
            echo "run.sh [-D | --devel] [-p | --port port] [ choreonoid (-- args) | assembler | jypyter | choreonoid-console | python (-- args) | ipython (-- args) ]"
            exit 0
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
dimage="repo.irsl.eiiris.tut.ac.jp/irsl_system:noetic"
if [ -n "${USE_DEVEL}" ]; then
    dimage="repo.irsl.eiiris.tut.ac.jp/irsl_system_devel:noetic"
fi

### parse program
OPT=""
cur_var=""
if [ "${PROG}" == "choreonoid" ]; then
    cur_var="-- choreonoid $*"
elif [ "${PROG}" == "assembler" ]; then
    RADIR=/choreonoid_ws/install/share/choreonoid-1.8/robot_assembler
    cur_var="-- choreonoid $RADIR/layout/assembler.cnoid --assembler $RADIR/irsl/irsl_assembler_config.yaml --original-project $RADIR/layout/original.cnoid"
elif [ "${PROG}" == "jupyter" ]; then
    cur_var="-- jupyter lab --allow-root --no-browser --ip=0.0.0.0 --port=${JUPYTER_PORT} --NotebookApp.token=''"
elif [ "${PROG}" == "choreonoid-console" ]; then
    OPT="-it"
    cur_var="-- jupyter console --kernel=Choreonoid"
elif [ "${PROG}" == "python" ]; then
    OPT="-it"
    cur_var="-- python3 $*"
elif [ "${PROG}" == "ipython" ]; then
    OPT="-it"
    cur_var="-- ipython $*"
fi

echo "image: $dimage"
echo "args: $cur_var"
DOCKER_CONTAINER=$CONTAINER_NAME \
DOCKER_IMAGE=$dimage \
MOUNTED_DIR=$WORK_DIR \
OPT=$OPT \
NO_GPU=$_NO_GPU \
USE_USER=$_USE_USER \
${abs_dir}/.run_docker_main.sh \
${cur_var}
