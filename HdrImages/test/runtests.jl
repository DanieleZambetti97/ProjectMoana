import HdrImages
using Test
using ColorTypes

img = HdrImages.HdrImage(5,2)
w = img.width
h = img.height
img = HdrImages.HdrImage(w,h,[ColorTypes.RGB(.0,.0,1.0*i) for i in 1:h*w])
new_col = ColorTypes.RGB(.0, .0, 999.9)
HdrImages.set_pixel(img, 1, 1, new_col)
HdrImages.set_pixel(img, 3, 2, new_col)

@testset "HdrImage" begin
    @test img.width == 5
    @test img.height == 2
    @test HdrImages.valid_coordinates(img, 4, 1) == true
    @test HdrImages.valid_coordinates(img, 5, 2) == true #the last element of the matrix has to be (5,2) and not (4,1) as in C++
    @test HdrImages.valid_coordinates(img,-1, 4) == false
    @test HdrImages.valid_coordinates(img, 0,-4) == false
    @test HdrImages.pixel_offset(img,1,1) == 1
    @test HdrImages.pixel_offset(img,3,2) == 8
    @test HdrImages.get_pixel(img, 1, 2) == 6
    @test HdrImages.get_pixel(img, 5, 2) == 10 
    @test img.pixels[1] == new_col
    @test img.pixels[8] == new_col
    
 end
