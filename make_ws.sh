#!/bin/bash

set -e

## SC=$(pwd)/make_ws.sh
## (cd your_target_workspace; bash $SC)

SCRIPT_DIR=$(cd $(dirname $0); pwd)

### install choreonoid
if [ "$ROS_DISTRO" = "noetic" -o "$ROS_DISTRO" = "one" ]; then
    wget https://raw.githubusercontent.com/IRSL-tut/irsl_choreonoid/main/config/dot.rosinstall
else
    wget https://raw.githubusercontent.com/IRSL-tut/irsl_choreonoid/devel_ros2_24.04/config/dot.rosinstall
fi

cat <<- _DOC_ >> dot.rosinstall
### IRSL settings >>> ###
- git:
    local-name: choreonoid_ros
    uri: https://github.com/IRSL-tut/choreonoid_ros.git
    version: stable
- git:
    local-name: irsl_choreonoid_ros
    uri: https://github.com/IRSL-tut/irsl_choreonoid_ros.git
    version: main
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
    patch -d src -p1 < src/irsl_choreonoid/config/choreonoid_closed_ik.patch && \
    find src/prioritized_qp src/ik_solvers src/qp_solvers \
         -name CMakeLists.txt -exec sed -i -e s@-std=c++[0-9][0-9]@-std=c++17@g {} \;

### add cgal to workspace for cnoid_cgal
(cd src; mkdir cgal; wget https://github.com/CGAL/cgal/releases/download/v5.6.2/CGAL-5.6.2.tar.xz -O - | tar Jxf - --strip-components 1 -C cgal)
#COPY files/cgal_package.xml src/cgal/package.xml
cp ${SCRIPT_DIR}/files/cgal_package.xml src/cgal/package.xml

## add robot_assembler
(cd src/choreonoid/ext; git clone https://github.com/IRSL-tut/robot_assembler_plugin.git)

## add jupyter_plugin
(cd src/choreonoid/ext; git clone https://github.com/IRSL-tut/jupyter_plugin.git)

sudo apt update -q -qq && \
    src/choreonoid/misc/script/install-requisites-ubuntu-$(lsb_release -s -r).sh && \
    if [ "$ROS_DISTRO" = "noetic" -o "$ROS_DISTRO" = "one" ]; then \
        sudo apt install -q -qq -y python3-catkin-tools libreadline-dev ; \
    else \
        sudo apt install -q -qq -y python-catkin-tools libreadline-dev ; \
    fi && \
    sudo apt install -q -qq -y libpulse-dev libsndfile-dev gstreamer1.0-libav libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev && \
    rosdep update -y -q -r && \
    rosdep install -y -q -r --ignore-src --from-path src/choreonoid_ros src/irsl_choreonoid_ros src/cnoid_cgal

# /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin config --cmake-args -DBUILD_TEST=ON -DBUILD_POSE_SEQ_PLUGIN=ON -DBUILD_BULLET_PLUGIN=ON -DBUILD_BALANCER_PLUGIN=ON -DBUILD_MOCAP_PLUGIN=ON -DBUILD_MEDIA_PLUGIN=ON && catkin config --install && catkin build irsl_choreonoid irsl_choreonoid_ros cnoid_cgal irsl_sim_environments irsl_detection_msgs irsl_detection_srvs irsl_raspi_controller --no-status --no-notify -p 1"
# /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build --parallel-workers 1 --merge-install --event-handlers console_direct+ desktop_notification- log_command+ status- --packages-up-to irsl_choreonoid"
