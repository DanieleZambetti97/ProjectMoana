#!/usr/bin/env julia

using Pkg
Pkg.activate(normpath(@__DIR__))

using Raytracer
using Colors
using ColorTypes
using Crayons

function main()
    c1 = RGB(0.1, 0.2, 0.3)
    c2 = RGB(0.1, 0.2, 0.3)
    s = 2

    println("This is the difference of the colors: $(c1 - c2)")
    println("This is the mult*scalar: $(c1*s)")
    
end

main()
