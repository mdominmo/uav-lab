#!/bin/bash
set -e

export GZ_SIM_RESOURCE_PATH="/gz_assets/models/"
export GZ_PARTITION="px4"

WORLD=""
OTHER_ARGS=()

for arg in "$@"; do
    if [[ "$arg" == *.sdf ]]; then
        WORLD="$arg"
    else
        OTHER_ARGS+=("$arg")
    fi
done

if [ -z "$WORLD" ]; then
    WORLD="$1"
    shift
fi

echo "WORLD: $WORLD"
echo "FLAGS: ${OTHER_ARGS[@]}"

cd /gz_assets/worlds && \
    gz sim -r "$WORLD" "${OTHER_ARGS[@]}"