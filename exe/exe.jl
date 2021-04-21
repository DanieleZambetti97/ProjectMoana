# #absolutely not important! Temporary file

import Pkg
Pkg.activate(normpath(@__DIR__))

import ColorTypes: RGB
import ProjectMoana: HdrImage
import ProjectMoana: _read_line
import ProjectMoana: _read_float
import ProjectMoana: read_pfm_image
import ProjectMoana: Vec
function main(ARGS)
    a=Vec(1,2,3.4)
    b=Vec(1,2,3.4)
    print(a+b)
end

main(ARGS)
