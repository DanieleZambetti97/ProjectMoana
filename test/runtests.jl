import ProjectMoana
using Test

@testset "HdrImages" begin
    include("test_HdrImages.jl")
end

@testset "RaytracerColors" begin
    include("test_Raytracer.jl")
end