module ProjectMoana

include("HdrImages.jl")
include("RaytracerColors.jl")
include("Geometry.jl")

greet(name) = println("Hello $(name)! Moana welcomes you!")
greet() = println("Hello User! Moana welcomes you!")

end # module
