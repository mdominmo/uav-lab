#!/bin/bash

trap handle_exit EXIT
function handle_exit() {
    echo "Exiting simulation."
    while read -r pid; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
    exit 0
}

run_cmd() {
    local cmd="$1" 
    if $VERBOSE; then
        echo "Executing: $cmd"
        (eval "$cmd" &)
        echo $! >> $PID_FILE
    else
        (eval "$cmd > /dev/null 2>&1 &")
        echo $! >> $PID_FILE 
    fi
}

VERBOSE=false
HEADLESS=false
execution_mode=""
conf_file=""

export GZ_PARTITION="px4"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|-s)
            execution_mode="$1"
            shift
            ;;
        -f)
            shift
            if [[ -z "$1" || "$1" == -* ]]; then
                echo "Error: -f requires a YAML file path."
                exit 1
            fi
            conf_file="$1"
            shift
            ;;
        -h|--headless)
            HEADLESS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 (-r,-s,-l) -f config.yaml [--verbose|-v]"
            exit 1
            ;;
    esac
done

if [[ -z "$execution_mode" || -z "$conf_file" ]]; then
    echo "Error: You must provide execution mode (-r,-s, or -l) and -f config.yaml"
    echo "Usage: $0 (-r,-s,-l) -f config.yaml [--verbose|-v]"
    exit 1
fi

VERBOSE=true
source /ros2/install/setup.bash

echo ""
echo "------------------------------"
echo "       Simulation Config      "
echo "------------------------------"
echo " Mode:        $execution_mode"
echo " Config file: $conf_file"
echo " Verbose:     $VERBOSE"
echo " Headless:    $HEADLESS"
echo "------------------------------"
echo ""


echo "Setting up the simulation environment..."

PID_FILE="/tmp/pids.txt"
> $PID_FILE

export PX4_GZ_WORLD=$(yq '.world.type' "$conf_file")
export GZ_SIM_RESOURCE_PATH="/gz_assets/models/"
export PX4_GZ_STANDALONE=1

SDF_FILE="/gz_assets/worlds/$PX4_GZ_WORLD.sdf"

declare -A swarm_pose
while IFS=": " read -r key value; do
    swarm_pose["$key"]=$value
done < <(yq '.UAS.swarm_pose | to_entries | map([.key, .value] | join(": ")) | .[]' "$conf_file")
y_0=${swarm_pose["y"]}

declare -A model
vehicle_instance=0
uavs=$(yq '.UAS.models[].name' "$conf_file")

for uav in $uavs; do
    while IFS=": " read -r key value; do
        model["$key"]=$value
    done < <(yq ".UAS.models[] | select(.name == \"$uav\") | to_entries | map([.key, .value] | join(\": \")) | .[]" "$conf_file")

    export PX4_SIM_MODEL="${model["name"]}"
    export PX4_SYS_AUTOSTART=${model["autostart"]}

    for ((i = 1; i <= model["number"]; i++)); do
        
        camera_topic="/world/${PX4_GZ_WORLD}/model/${PX4_SIM_MODEL}_${vehicle_instance}/link/mono_cam/base_link/sensor/camera/image"
        camera_topics="$camera_topics $camera_topic"

        swarm_pose["y"]=$((y_0 - vehicle_instance * 2))
        export PX4_GZ_MODEL_POSE="${swarm_pose["x"]},${swarm_pose["y"]},${swarm_pose["z"]},${swarm_pose["R"]},${swarm_pose["P"]},${swarm_pose["Y"]}"

        run_cmd "/PX4-Autopilot/build/px4_sitl_default/bin/px4 -i $vehicle_instance"
        sleep 10

        vehicle_instance=$((vehicle_instance+=1))
    done
done

run_cmd "ros2 run ros_gz_image image_bridge $camera_topics"
sleep 5

run_cmd "MicroXRCEAgent udp4 -p 8888"
sleep 5

echo "starting gz server..."
if [ "$HEADLESS" == true ]; then
    gz sim -r -s $SDF_FILE
else
    echo "With GUI."
    gz sim -r $SDF_FILE
fi
echo $! >> $PID_FILE