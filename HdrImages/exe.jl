#!/usr/bin/env julia

import Pkg
Pkg.activate(normpath(@__DIR__))

import ColorTypes
import HdrImages

function main(ARGS)
    w = parse(Int, ARGS[1])
    h = parse(Int, ARGS[2])

    img = HdrImages.HdrImage(w,h,[ColorTypes.RGB(.0,.0,.01*i) for i in 1:h*w])
    println("This image has:\n  - $(img.width) columns\n  - $(img.height) rows")
    
    for i in 1:h
        for j in 1:w
            print("$(HdrImages.pixel_offset(img,j,i)), $(img.pixels[HdrImages.pixel_offset(img,j,i)]) ")
        end
    println()
    end

    io = IOBuffer()
    write(io, img)
    println(String(take!(io)))

end

main(ARGS)
