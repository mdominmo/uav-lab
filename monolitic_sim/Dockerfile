FROM px4io/px4-dev-simulation-jammy AS px4_builder

ENV DEBIAN_FRONTEND=noninteractive
RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive

RUN cd PX4-Autopilot && \
    git checkout 99c40407ffd7ac184e2d7b4b293f36f10fe561ef 

RUN apt-get update && \
    apt-get install -y curl lsb-release gnupg && \
    curl https://packages.osrfoundation.org/gazebo.gpg \
    --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get install -y gz-harmonic

RUN cd PX4-Autopilot && \
    make distclean && \
    make px4_sitl -j"$(nproc)"


FROM ubuntu:jammy AS uxrce_builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
            software-properties-common \
            build-essential \
            cmake \
            git

RUN apt install -y openjdk-8-jdk
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64/"
RUN apt-get install -y gradle
RUN apt-get clean

RUN git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git

RUN cd Micro-XRCE-DDS-Agent && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=../install .. && \
    make -j $(nproc) && make install

RUN cd Micro-XRCE-DDS-Agent && \
    tar -czvf install.tar.gz  -C install .


FROM px4io/px4-dev-simulation-jammy AS runtime

ENV DEBIAN_FRONTEND=noninteractive
COPY --from=uxrce_builder /Micro-XRCE-DDS-Agent/install.tar.gz  /usr/local/
RUN tar -xzvf /usr/local/install.tar.gz -C /usr/local/ && \
    rm /usr/local/install.tar.gz

COPY --from=uxrce_builder /Micro-XRCE-DDS-Agent/agent.refs .
RUN ldconfig

COPY --from=px4_builder /PX4-Autopilot/build /PX4-Autopilot/build

RUN apt-get update && \
    apt-get install -y curl lsb-release gnupg && \
    curl https://packages.osrfoundation.org/gazebo.gpg \
    --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get install -y \
    gz-harmonic

RUN apt-get update && apt-get install -y curl \
    && curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
       -o /usr/bin/yq \
    && chmod +x /usr/bin/yq

RUN mkdir -p /ros2/src && \
    cd /ros2/src && \
    git clone https://github.com/PX4/px4_msgs.git && \
    cd px4_msgs && \
    git checkout 1ebaae499d5e11f43ec7d82c42cf6e73dd26e163

RUN apt update && apt install -y curl gnupg && \
    mkdir -p /usr/share/keyrings && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" > /etc/apt/sources.list.d/ros2.list && \
    apt update

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-pip \
    python3-colcon-common-extensions \
    lsb-release \
    ros-humble-ros-base \
    ros-humble-ament-cmake \
    ros-humble-ament-cmake-auto \
    ros-humble-ament-cmake-python \
    ros-humble-rosidl-default-generators \
    ros-humble-cv-bridge \
    ros-humble-geographic-msgs \
    ros-humble-ros-gzharmonic \
    && rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

RUN . /opt/ros/humble/setup.sh && \
    cd /ros2 && \
    colcon build && \
    echo "source /ros2/install/setup.bash" >> /root/.bashrc

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    mesa-utils \
    x11-apps

COPY scripts /scripts
RUN chmod -R +x /scripts

ENTRYPOINT ["/bin/bash"]
CMD ["/scripts/launch_simulator.sh", "-s", "-f", "/simulation_templates/riai_planner_paper_world.yaml"]