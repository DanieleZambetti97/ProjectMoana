# Executble for printing colors!

using Pkg
Pkg.activate(normpath(@__DIR__))

using ProjectMoana

function main(ARGS)
    if length(ARGS)==3 && 0 <= parse(Float32, ARGS[1]) <= 1 && 0 <= parse(Float32, ARGS[2]) <= 1 && 0 <= parse(Float32, ARGS[3]) <= 1
        a = (parse(Float32, ARGS[1]), parse(Float32, ARGS[2]), parse(Float32, ARGS[3]))
        b = round.(Int, a .* 255)
        printcol(b)
    else
        println("Pass me a RGB color \ne.g. 1.0 0.4 0.6")
    end
end

main(ARGS)
