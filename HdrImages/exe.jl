#!/usr/bin/env julia

using Pkg
Pkg.activate(normpath(@__DIR__))

using ColorTypes
using HdrImages

function main(ARGS)
    w = parse(Int, ARGS[1])
    h = parse(Int, ARGS[2])

    img = HdrImages.HdrImage(w,h)
    println("$(img.pixels)")

    println( HdrImages.valid_coordinates(img, 1, 2) )
end

main(ARGS)
