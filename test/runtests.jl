using ProjectMoana
using Test

@testset "RaytracerColors" begin
    include("test_Raytracer.jl")
end

@testset "HdrImages" begin
    include("test_HdrImages.jl")
end

