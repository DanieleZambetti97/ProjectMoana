# Executble for printing colors!
#!/usr/bin/env julia

using Pkg
Pkg.activate(normpath(@__DIR__))

using Raytracer
using Colors
using ColorTypes
using Crayons

function main(ARGS)
    a = (parse(Float32, ARGS[1]), parse(Float32, ARGS[2]), parse(Float32, ARGS[3]))
    b = round.(Int, a .* 255)

    Raytracer.printcol(b)

end

main(ARGS)