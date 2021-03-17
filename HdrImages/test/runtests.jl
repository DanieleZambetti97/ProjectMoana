using HdrImages
using Test

img= HdrImages.HdrImage(10,15)
@testset "HdrImage" begin
    @test img.width == 10
    @test img.heigth == 15
    @test HdrImages.valid_coordinates(img, 1, 7) == true
    @test HdrImages.valid_coordinates(img,-1, 4) == false
    @test HdrImages.valid_coordinates(img, 0,-4) == false
    @test HdrImages.pixel_offset(img,1,1) == 1
    @test HdrImages.pixel_offset(img,10,3) == 30

end
