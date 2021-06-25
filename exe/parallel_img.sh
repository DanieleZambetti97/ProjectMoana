#!/bin/bash

if [ "$5" == "" ]; then
    echo "Usage: $(basename $0) SEQ"
    exit 1
fi

readonly SCENE_FILE="$1"
readonly WIDTH="$2"
readonly HEIGHT="$3"
readonly ALG="$4"
readonly S="$5"
readonly RAYS_PER_PIXEL="$6"
readonly NUM_OF_RAYS="$7"
readonly DEPTH="$8"
readonly RUSSIAN_ROULETTE="$9"
readonly FILENAME="${10}"

readonly seqNNN=$(printf "%03d" $S)

readonly filename=$FILENAME$seqNNN

# echo "parallel_img.sh con seq=${S}"
# echo "${SCENE_FILE}"
# echo "${WIDTH}"
# echo "${HEIGHT}"
# echo "${ALG}"
# echo "${S}"
# echo "${RAYS_PER_PIXEL}"
# echo "${NUM_OF_RAYS}"
# echo "${DEPTH}"
# echo "${RUSSIAN_ROULETTE}"
# echo "${FILENAME}"

julia render.jl --scene ${SCENE_FILE} --w ${WIDTH} --h ${HEIGHT} --alg ${ALG} --seq ${S} --pix_rays ${RAYS_PER_PIXEL} --rays ${NUM_OF_RAYS} --d ${DEPTH} --rr ${RUSSIAN_ROULETTE} --file_out ${filename} 
