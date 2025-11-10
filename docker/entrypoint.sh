#!/bin/bash
# Basic entrypoint for ROS Docker containers

# Source ROS 2
source /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS 2 ${ROS_DISTRO}"

source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash

# Source the base workspace, if built
if [ -f /bringup_ws/install/setup.bash ]
then
  source /bringup_ws/install/setup.bash
  echo "Sourced bringup_ws"
fi

# Source the sim workspace, if built
if [ -f /sim_ws/install/setup.bash ]
then
  source /sim_ws/install/setup.bash
  echo "Sourced sim_ws"
fi

# Source the overlay workspace, if built
if [ -f /overlay_ws/install/setup.bash ]
then
  source /overlay_ws/install/setup.bash
  echo "Sourced overlay_ws"
fi

# Execute the command passed into this entrypoint
exec "$@"