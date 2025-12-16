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


# Useful aliases
alias sb='source ~/.bashrc'
alias sw='source /${DEV_BASE}/install/setup.bash'
alias rl='ros2 topic list'
alias re='ros2 topic echo'
alias tel='ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -p stamped:=true'

# Useful helper functions
# -----------------------
# Build the entire workspace
function rb() {
        cd /${DEV_BASE}
        colcon build --symlink-install
        cd -
}

# Build selected packages
function rbsp() {
        cd /${DEV_BASE}
        colcon build --symlink-install --packages-select $@
        cd -
}

# Run rosdep install for the workspace
function rdep() {
        cd /${DEV_BASE}
        sudo apt install python3-rosdep && rosdep update && rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y
        cd -
}


# Execute the command passed into this entrypoint
exec "$@"