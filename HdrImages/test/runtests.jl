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

#= img = HdrImage(3, 2)

HdrImages.set_pixel(img, 0, 0, Color(1.0e1, 2.0e1, 3.0e1)) # Each component is
HdrImages.set_pixel(img, 1, 0, Color(4.0e1, 5.0e1, 6.0e1)) # different from any
HdrImages.set_pixel(img, 2, 0, Color(7.0e1, 8.0e1, 9.0e1)) # other: important in
HdrImages.set_pixel(img, 0, 1, Color(1.0e2, 2.0e2, 3.0e2)) # tests!
HdrImages.set_pixel(img, 1, 1, Color(4.0e2, 5.0e2, 6.0e2))
HdrImages.set_pixel(img, 2, 1, Color(7.0e2, 8.0e2, 9.0e2))

open("reference_le.pfm", "wb") do f
    write(reference_bytes,

buf = BytesIO()
write(buf, img)
    @test buf == reference_bytes
 =#
 end
