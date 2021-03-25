#!/usr/bin/env julia

import Pkg
Pkg.activate(normpath(@__DIR__))

using ImportMacros

@import ColorTypes as CT
@import HdrImages as Hdr

function main(ARGS)
    w = parse(Int, ARGS[1])
    h = parse(Int, ARGS[2])

    img = Hdr.HdrImage(w,h,[CT.RGB(1,13,.01*i) for i in 1:h*w])
    println("This image has:\n  - $(img.width) columns\n  - $(img.height) rows")
    
    #=for i in 1:h
        for j in 1:w
            print("$(Hdr.pixel_offset(img,j,i)), $(img.pixels[Hdr.pixel_offset(img,j,i)]) ")
        end
    println()
    end
    =#

    
    img2 = Hdr.read_pfm_image("reference_be.pfm")
    print(img2)

    
end

main(ARGS)
