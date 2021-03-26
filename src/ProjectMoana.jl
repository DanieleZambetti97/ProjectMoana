module ProjectMoana

include("HdrImages.jl")
include("RaytracerColors.jl")

greet(name) = println("Hello $(name)! Moana welcomes you!")
greet() = println("Hello World! Moana welcomes you!")

end # module
