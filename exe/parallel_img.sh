#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) SEQ"
    exit 1
fi

readonly SCENE_FILE="$2"
readonly WIDTH="$3"
readonly HEIGHT="$4"
readonly ALG="$5"
readonly RAYS_PER_PIXEL="$6"
readonly NUM_OF_RAYS="$7"
readonly DEPTH="$8"
readonly RUSSIAN_ROULETTE="$9"
readonly FILENAME="${10}"
readonly S="$1"


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

julia render.jl --scene ${SCENE_FILE} --w ${WIDTH} --h ${HEIGHT} --alg ${ALG} --seq ${S} --pix_rays ${RAYS_PER_PIXEL} --rays ${NUM_OF_RAYS} --d ${DEPTH} --rr ${RUSSIAN_ROULETTE} --file_out ${filename}

