using HdrImages
using Test

img= HdrImages.HdrImage(10,15)
@testset "HdrImage" begin
    @test HdrImages.valid_coordinates(img,1,7) == true
end
