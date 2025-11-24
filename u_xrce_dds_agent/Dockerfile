FROM ubuntu:jammy AS builder
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


FROM ubuntu:jammy

COPY --from=builder /Micro-XRCE-DDS-Agent/install.tar.gz  /usr/local/
RUN tar -xzvf /usr/local/install.tar.gz -C /usr/local/ && \
    rm /usr/local/install.tar.gz

COPY --from=builder /Micro-XRCE-DDS-Agent/agent.refs .
RUN ldconfig

ENTRYPOINT ["MicroXRCEAgent", "udp4", "-p", "8888"]