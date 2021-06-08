#!/bin/bash

file_begin="$1"

parallel --ungroup -j 4 ./parallel_img.sh '{}' $file_begin ::: $(seq 0 3)

julia parallel_sum.jl $file_begin

#find "." -name $file_begin"0*" -type f -delete

