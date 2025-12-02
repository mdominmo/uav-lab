#!/bin/bash
set -e

xhost +local:docker

cd "$(dirname "${BASH_SOURCE[0]}")"

docker run -it \
    --network host \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v "$(pwd)/../gz_assets:/gz_assets" \
    -v "$(pwd)/../simulation_templates:/simulation_templates" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    monolitic_sim