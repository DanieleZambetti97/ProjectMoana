import HdrImages
using Test

img= HdrImages.HdrImage(5,2)
@testset "HdrImage" begin
    @test img.width == 5
    @test img.height == 2
    @test HdrImages.valid_coordinates(img, 4, 1) == true
    @test HdrImages.valid_coordinates(img,-1, 4) == false
    @test HdrImages.valid_coordinates(img, 0,-4) == false
    @test HdrImages.pixel_offset(img,1,1) == 1
    @test HdrImages.pixel_offset(img,3,2) == 8

end
