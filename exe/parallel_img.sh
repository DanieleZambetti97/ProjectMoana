#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) SEQ"
    exit 1
fi

readonly SCENE_FILE="$2"
readonly ANIMATION_VAR="$3"
readonly WIDTH="$4"
readonly HEIGHT="$5"
readonly FILENAME="$6"
readonly ALG="$7"
readonly S="$1"
readonly NUM_OF_RAYS="$8"

readonly seqNNN=$(printf "%03d" $S)

readonly filename=$FILENAME$seqNNN

# echo "parallel_img.sh con seq=${S}"
# echo "${SCENE_FILE}"
# echo "${ANIMATION_VAR}"
# echo "${WIDTH}"
# echo "${HEIGHT}"
# echo "${filename}"
# echo "${ALG}"
# echo "${S}"
# echo "${NUM_OF_RAYS}"

julia render.jl --scene ${SCENE_FILE} --anim_var ${ANIMATION_VAR} --w ${WIDTH} --h ${HEIGHT} --file_out ${filename} --render_alg ${ALG} --seq ${S} --nrays ${NUM_OF_RAYS}

#time julia demo_pathtracer.jl --width 1280 --height 960 --seq $seq --file_out $filename
