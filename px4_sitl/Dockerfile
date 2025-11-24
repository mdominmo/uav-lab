FROM px4io/px4-dev-simulation-jammy AS builder

RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive

RUN cd PX4-Autopilot && \
    git checkout 33841cf43896478b86766cb2b09526fe5c88e49c 

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


FROM px4io/px4-dev-simulation-jammy AS runtime

COPY --from=builder /PX4-Autopilot/build /PX4-Autopilot/build

RUN apt-get update && \
    apt-get install -y curl lsb-release gnupg && \
    curl https://packages.osrfoundation.org/gazebo.gpg \
    --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get install -y gz-harmonic

ENV INSTANCE_ID=1
ENV PX4_SIM_MODEL="x500_mono_cam"
ENV PX4_SYS_AUTOSTART=4001
ENV PX4_UXRCE_DDS_NS="px4_1"
ENV PX4_GZ_STANDALONE=1
ENV GZ_PARTITION="px4"
ENV PX4_GZ_WORLD="test_world"
ENV GZ_RELAY=1
ENV GZ_DISCOVERY_SERVER=127.0.0.1:11345

ENTRYPOINT ["sh", "-c", "/PX4-Autopilot/build/px4_sitl_default/bin/px4 -i ${INSTANCE_ID}"]
