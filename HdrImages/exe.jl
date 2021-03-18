#!/usr/bin/env julia

import Pkg
Pkg.activate(normpath(@__DIR__))

import ColorTypes
import HdrImages

function main(ARGS)
    w = parse(Int, ARGS[1])
    h = parse(Int, ARGS[2])

    img = HdrImages.HdrImage(w,h,[ColorTypes.RGB(.0,.0,.01*i) for i in 1:h*w])
    println("L'immagine che hai creato ha:\n  - $(img.width) di colonne\n  - $(img.height) di righe")
    
    for i in 1:h
        for j in 1:w
            print("$(HdrImages.pixel_offset(img,j,i)), $(img.pixels[HdrImages.pixel_offset(img,j,i)]) ")
        end
    println()
    end
end

main(ARGS)
