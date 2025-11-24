FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y \
    curl \ 
    gnupg

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" \
    > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && \
    apt-get install -y curl lsb-release gnupg && \
    curl https://packages.osrfoundation.org/gazebo.gpg \
    --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null 

RUN apt-get update && \
    apt-get install -y \
    ros-humble-ros-base \
    ros-humble-ros-gzharmonic \
    gz-harmonic

SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV GZ_DISCOVERY_SERVER=127.0.0.1:11345
ENV GZ_PARTITION=px4
ENV GZ_RELAY=1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/world/test_world/model/x500_mono_cam_3/link/mono_cam/base_link/sensor/camera/image"]