using ProjectMoana
using ColorTypes


@testset "Colors basic operation" begin
    @test RGB(.1,.3,.5)+RGB(.4,.6,.2) ≈ RGB(.5,.9,.7)
    @test RGB(.8,.7,.5)-RGB(.4,.6,.2) ≈ RGB(.4,.1,.3)
    @test RGB(1,.4,.4)*2 ≈ RGB(2,.8,.8)
    @test 3*RGB(.1,.2,.3) ≈ RGB(.3,.6,.9)
end
