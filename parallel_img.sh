#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) SEQ"
    exit 1
fi

readonly file_begin=images/prova_07_

readonly seq="$1"
readonly seqNNN=$(printf "%03d" $seq)
readonly filename=$file_begin$seqNNN
time julia demo.jl --width 640 --height 480 --seq $seq --file_out $filename

#parallel -j 4 ./parallel_img.sh '{}' ::: $(seq 0 3)