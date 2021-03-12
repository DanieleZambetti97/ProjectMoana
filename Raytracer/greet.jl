#!/usr/bin/env julia

using Pkg
Pkg.activate(normpath(@__DIR__))

using Raytracer
using Colors
using ColorTypes
using Crayons

function main(ARGS)

    isempty(ARGS)== true ? Raytracer.greet() : Raytracer.greet(ARGS[1])
    
end

main(ARGS)
