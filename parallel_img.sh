#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) ANGLE"
    exit 1
fi

readonly seq="$1"
readonly seqNNN=$(printf "%03d" $seq)
readonly filename=image$seqNNN


time julia demo.jl --width 640 --height 480 --seq $seq --file_out $filename

#parallel -j 4 ./parallel_img.sh '{}' ::: $(seq 0 4)