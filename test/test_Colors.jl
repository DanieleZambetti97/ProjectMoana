using ProjectMoana
using ColorTypes


@testset "Colors: Basic operation    " begin
    @test RGB(.1,.3,.5)+RGB(.4,.6,.2) ≈ RGB(.5,.9,.7)
    @test RGB(.8,.7,.5)-RGB(.4,.6,.2) ≈ RGB(.4,.1,.3)
    @test RGB(1,.4,.4)*2 ≈ RGB(2,.8,.8)
    @test 3*RGB(.1,.2,.3) ≈ RGB(.3,.6,.9)
end

col1 = RGB(1.0, 2.0, 3.0)
col2 = RGB(9.0, 5.0, 7.0)

@testset "Colors: Luminosity function" begin
    @test isapprox(luminosity(col1), 2.0)
    @test isapprox(luminosity(col2), 7.0)
end
