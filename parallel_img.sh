#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) SEQ"
    exit 1
fi

readonly file_begin=images/prova_09_

readonly seq="$1"
readonly seqNNN=$(printf "%03d" $seq)
readonly filename=$file_begin$seqNNN
time julia demo.jl --width 1280 --height 960 --seq $seq --file_out $filename

#parallel --ungroup -j 4 ./parallel_img.sh '{}' ::: $(seq 0 3)