#!/bin/bash

set -e

## SC=$(pwd)/make_ws.sh
## (cd your_target_workspace; bash $SC)

SCRIPT_DIR=$(cd $(dirname $0); pwd)

### install choreonoid
if [ "${ROS_DISTRO}" == "noetic" -o "${ROS_DISTRO}" == "one" ]; then
    wget https://raw.githubusercontent.com/IRSL-tut/irsl_choreonoid/main/config/dot.rosinstall  -O dot.rosinstall
    CNOID_ROS_VER='stable';
    CNOID_ROS_NAME='choreonoid_ros';
    CNOID_ROS_REPO='https://github.com/IRSL-tut/choreonoid_ros.git';
    IRSL_CNOID_ROS='main';
else
    wget https://raw.githubusercontent.com/IRSL-tut/irsl_choreonoid/main/config/dot.ros2install -O dot.rosinstall
    CNOID_ROS_VER='devel';
    CNOID_ROS_NAME='choreonoid_ros2';
    CNOID_ROS_REPO='https://github.com/IRSL-tut/choreonoid_ros2.git';
    IRSL_CNOID_ROS='devel_ros2_24.04';
fi
cat <<- _DOC_ >> dot.rosinstall
### IRSL settings >>> ###
- git:
    local-name: ${CNOID_ROS_NAME}
    uri: ${CNOID_ROS_REPO}
    version: ${CNOID_ROS_VER}
- git:
    local-name: irsl_choreonoid_ros
    uri: https://github.com/IRSL-tut/irsl_choreonoid_ros.git
    version: ${IRSL_CNOID_ROS}
- git:
    local-name: cnoid_cgal
    uri: https://github.com/IRSL-tut/cnoid_cgal.git
- git:
    local-name: irsl_sim_environments
    uri: https://github.com/IRSL-tut/irsl_sim_environments.git
- git:
    local-name: irsl_ros_msgs
    uri: https://github.com/IRSL-tut/irsl_ros_msgs.git
- git:
    local-name: irsl_raspi_controller
    uri: https://github.com/IRSL-tut/irsl_raspi_controller.git
- git:
    local-name: irsl_python_lib
    uri: https://github.com/IRSL-tut/irsl_python_lib.git
### IRSL settings <<< ###
_DOC_

source /opt/ros/${ROS_DISTRO}/setup.bash && \
    (mkdir src; cd src; vcs import --recursive < ../dot.rosinstall) && \
    sed -i -e "s@osqp-cpp src/osqp++.cc@osqp-cpp SHARED src/osqp++.cc@g" src/qp_solvers/osqp-cpp/osqp-cpp/CMakeLists.txt && \
    find src/prioritized_qp src/ik_solvers src/qp_solvers \
         -name CMakeLists.txt -exec sed -i -e s@-std=c++[0-9][0-9]@-std=c++17@g {} \;
##    patch -d src -p1 < src/irsl_choreonoid/config/choreonoid_closed_ik.patch && \

### add cgal to workspace for cnoid_cgal
if $(echo -e "$(lsb_release -s -r)\n20.04" | sort -C -V); then \
    (cd src; mkdir cgal; wget -q https://github.com/CGAL/cgal/releases/download/v5.6.2/CGAL-5.6.2.tar.xz -O - | tar Jxf - --strip-components 1 -C cgal)
else
    (cd src; mkdir cgal; wget -q https://github.com/CGAL/cgal/releases/download/v6.2/CGAL-6.2.tar.xz -O - | tar Jxf - --strip-components 1 -C cgal)
fi
#COPY files/cgal_package.xml src/cgal/package.xml
cp ${SCRIPT_DIR}/files/cgal_package.xml src/cgal/package.xml

## add robot_assembler
(cd src/choreonoid/ext; git clone https://github.com/IRSL-tut/robot_assembler_plugin.git)

## add jupyter_plugin
(cd src/choreonoid/ext; git clone https://github.com/IRSL-tut/jupyter_plugin.git)

## add irsl_cnoid_plugin
(cd src/choreonoid/ext; git clone https://github.com/IRSL-tut/irsl_cnoid_plugin.git)

sudo apt update -q -qq && \
    if $(echo -e "23.10\n$(lsb_release -s -r)" | sort -C -V); then \
        UBUNTU_VER=24.04; \
    else \
        UBUNTU_VER=$(lsb_release -s -r); \
    fi && \
    src/choreonoid/misc/script/install-requisites-ubuntu-${UBUNTU_VER}.sh && \
    if [ "$ROS_DISTRO" = "noetic" -o "$ROS_DISTRO" = "one" ]; then \
        sudo apt install -q -qq -y python3-catkin-tools libreadline-dev ; \
    elif [ "$ROS_DISTRO" = "lyrical" -o  "$ROS_DISTRO" = "jazzy" -o "$ROS_DISTRO" = "humble" -o "$ROS_DISTRO" = "rolling" ]; then \
        sudo apt install -q -qq -y libreadline-dev ; \
    else \
        sudo apt install -q -qq -y python-catkin-tools libreadline-dev ; \
    fi && \
    sudo apt install -q -qq -y libpulse-dev libsndfile-dev gstreamer1.0-libav libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev && \
    rosdep update -y -q -r && \
    rosdep install -y -q -r --ignore-src --from-path src/choreonoid_ros* src/irsl_choreonoid_ros src/cnoid_cgal

if [ "${ROS_DISTRO}" == "noetic" -o "${ROS_DISTRO}" == "one" ]; then
    ## build using catkin
    echo 'run command below';
    echo '/bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin config --cmake-args -DBUILD_TEST=ON -DBUILD_POSE_SEQ_PLUGIN=ON -DBUILD_BULLET_PLUGIN=ON -DBUILD_BALANCER_PLUGIN=ON -DBUILD_MOCAP_PLUGIN=ON -DBUILD_MEDIA_PLUGIN=ON && catkin config --install && catkin build irsl_choreonoid irsl_choreonoid_ros cnoid_cgal irsl_sim_environments irsl_detection_msgs irsl_detection_srvs irsl_raspi_controller --no-status --no-notify -p 1"';
else
    ## build using ament
    echo 'run command below';
    echo '/bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build --parallel-workers 1 --merge-install --event-handlers console_direct+ desktop_notification- log_command+ status- --cmake-args -DCMAKE_POLICY_VERSION_MINIMUM=3.5 --ament-cmake-args -DCMAKE_POLICY_VERSION_MINIMUM=3.5 --packages-up-to irsl_choreonoid_ros"';
fi
