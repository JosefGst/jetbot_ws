# ROS distribution to use
ARG ROS_DISTRO=jazzy
ARG DEV_BASE=bringup
ARG BRINGUP_BASE=bringup

########################################
# bringup Jetbot Robot                 #
########################################
FROM ros:${ROS_DISTRO} AS bringup
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

# Install basic apt packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git libcanberra-gtk-module libcanberra-gtk3-module fuse3 libfuse2 libqt5svg5-dev 

# Install additional ROS packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-rmw-zenoh-cpp

ENV RMW_IMPLEMENTATION=rmw_zenoh_cpp

# Create Colcon workspace with external dependencies
RUN mkdir -p /bringup_ws/src
WORKDIR /bringup_ws/src
COPY ./src/bringup/ ./bringup/
RUN vcs import bringup < bringup/bringup.repos

# Build YDLIDAR SDK from source
WORKDIR /bringup_ws/src/bringup/YDLidar-SDK
RUN mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install

# # # Build the base Colcon workspace, installing dependencies first.
WORKDIR /bringup_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && apt-get update -y \
    && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
    && colcon build --symlink-install \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# # Remove display warnings
# RUN mkdir /tmp/runtime-root
# ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
# RUN chmod -R 0700 /tmp/runtime-root
# ENV NO_AT_BRIDGE 1



# Set up the entrypoint
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["bash"]


# ########################################
# # Simulation                           #
# ########################################
# FROM ros:${ROS_DISTRO} AS sim
# ENV ROS_DISTRO=${ROS_DISTRO}
# SHELL ["/bin/bash", "-c"]

# # Install basic apt packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git libcanberra-gtk-module libcanberra-gtk3-module fuse3 libfuse2 libqt5svg5-dev 

# # Install additional ROS packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ros-${ROS_DISTRO}-rviz2 \
#     ros-${ROS_DISTRO}-rmw-zenoh-cpp

# ENV RMW_IMPLEMENTATION=rmw_zenoh_cpp

# # # Create Colcon workspace with external dependencies
# RUN mkdir -p /sim_ws
# WORKDIR /sim_ws/src
# COPY ../sim/ ./sim/
# # RUN vcs import sim < sim/sim.repos

# # # Build the base Colcon workspace, installing dependencies first.
# WORKDIR /sim_ws
# RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
#     && apt-get update -y \
#     && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
#     && colcon build --symlink-install \
#     # Clean up
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*
# ENV TURTLEBOT3_MODEL=waffle_pi

# # Remove display warnings
# RUN mkdir /tmp/runtime-root
# ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
# RUN chmod -R 0700 /tmp/runtime-root
# ENV NO_AT_BRIDGE 1



# # Set up the entrypoint
# COPY ./docker/entrypoint.sh /
# ENTRYPOINT [ "/entrypoint.sh" ]
# CMD ["bash"]


# ########################################
# # overlay                              #
# ########################################
# FROM ${BRINGUP_BASE} AS overlay
# ENV ROS_DISTRO=${ROS_DISTRO}
# SHELL ["/bin/bash", "-c"]

# # # Create Colcon workspace with external dependencies
# RUN mkdir -p /overlay_ws
# WORKDIR /overlay_ws/src
# COPY ../overlay/ ./overlay/
# RUN vcs import overlay < overlay/overlay.repos

# # # Build the base Colcon workspace, installing dependencies first.
# WORKDIR /overlay_ws
# RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
#     && apt-get update -y \
#     && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
#     && colcon build --symlink-install \
#     # Clean up
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*

# # Set up the entrypoint
# COPY ./docker/entrypoint.sh /
# ENTRYPOINT [ "/entrypoint.sh" ]
# CMD ["bash"]


#####################
# Development Image #
#####################
# TODO: Seems like can be specified in docker-compose file only?

FROM ${DEV_BASE} AS dev
ARG DEV_BASE
RUN echo "build ${DEV_BASE} dev image"
# Dev container arguments
ARG USERNAME=devuser
ARG UID=1000
ARG GID=${UID}

# Install extra tools for development
RUN apt-get update && apt-get install -y --no-install-recommends \
    gdb gdbserver vim \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rqt-graph \
    # # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# In Ubuntu 24.04, there is already a user named "ubuntu" with UID 1000.
# Delete this in the (common) event that the user on the host also has this UID.
RUN touch /var/mail/ubuntu \
    && chown ubuntu /var/mail/ubuntu \
    && userdel -r ubuntu

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME} \
    && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the bringup workspace to the new user
RUN chown -R ${UID}:${GID} /${DEV_BASE}_ws/

# Set the user and source entrypoint in the user's .bashrc file
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc

WORKDIR /${DEV_BASE}_ws/
