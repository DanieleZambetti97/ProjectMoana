#!/usr/bin/env julia

using Pkg
Pkg.activate(normpath(@__DIR__))

using Raytracer
using Colors
using ColorTypes
using Crayons

function main(ARGS)

    name = ARGS[1]

    Raytracer.greet(name)    
    
end

main(ARGS)
