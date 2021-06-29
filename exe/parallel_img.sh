#!/bin/bash

if [ "$5" == "" ]; then
    echo "Usage: $(basename $0) SEQ"
    exit 1
fi

readonly SCENE_FILE="$1"
readonly ALG="$2"
readonly S="$3"
readonly RAYS_PER_PIXEL="$4"
readonly NUM_OF_RAYS="$5"
readonly DEPTH="$6"
readonly RUSSIAN_ROULETTE="$7"
readonly FILENAME="$8"

readonly seqNNN=$(printf "%03d" $S)

readonly filename=$FILENAME$seqNNN

# echo "parallel_img.sh con seq=${S}"
# echo "${SCENE_FILE}"
# echo "${ALG}"
# echo "${S}"
# echo "${RAYS_PER_PIXEL}"
# echo "${NUM_OF_RAYS}"
# echo "${DEPTH}"
# echo "${RUSSIAN_ROULETTE}"
# echo "${FILENAME}"

julia render.jl --scene ${SCENE_FILE} --alg ${ALG} --seq ${S} --pix_rays ${RAYS_PER_PIXEL} --rays ${NUM_OF_RAYS} --d ${DEPTH} --rr ${RUSSIAN_ROULETTE} --file_out ${filename} 
