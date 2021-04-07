# #absolutely not important! Temporary file

import Pkg
Pkg.activate(normpath(@__DIR__))

import ColorTypes: RGB
import ProjectMoana: HdrImage
import ProjectMoana: _read_line
import ProjectMoana: _read_float
import ProjectMoana: read_pfm_image

function main(ARGS)
    if length(ARGS)==2 &&  parse(Float32, ARGS[1])>0 && parse(Float32, ARGS[2])>0
        w, h = parse(Int, ARGS[1]), parse(Int, ARGS[2])
        img = HdrImage(w,h,[RGB(1,13,.01*i) for i in 1:h*w])
        println("This image has:\n  - $(img.width) columns\n  - $(img.height) rows")
    else
        println("Pass me a HdrImage(w,h,pixels) or HdrImages(w,h)\ne.g. julia exe.jl 3 15")
    end

end

main(ARGS)
