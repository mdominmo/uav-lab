#!/bin/bash
set -e

docker run -it --network host \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v gz_assets:/gz_assets \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    gz_sim -s test_world.sdf