import HdrImages
using Test
using ColorTypes

# TESTING THE BASIC METHODS FOR HdrImages 

img = HdrImages.HdrImage(3, 2)

@testset "HdrImage Basic Methods" begin
    @test img.width == 3
    @test img.height == 2
    @test HdrImages.valid_coordinates(img, 2, 1) == true
    @test HdrImages.valid_coordinates(img, 3, 2) == true #the last element of the matrix has to be (3,2) and not (2,1) as in C++
    @test HdrImages.valid_coordinates(img,-1, 4) == false
    @test HdrImages.valid_coordinates(img, 0, 4) == false
    @test HdrImages.pixel_offset(img,1,1) == 1
    @test HdrImages.pixel_offset(img,2,2) == 5
    @test HdrImages.get_pixel(img, 1, 2) == 4
    @test HdrImages.get_pixel(img, 3, 1) == 3 

new_col = ColorTypes.RGB(.012, 34, 999.9)
HdrImages.set_pixel(img, 1, 1, new_col)
HdrImages.set_pixel(img, 3, 2, new_col)

    @test img.pixels[1] == new_col
    @test img.pixels[HdrImages.get_pixel(img, 3, 2)] == new_col
    
end

# TESTING THE WRITING/READING METHODS FOR HdrImages 

# Set pixels colors like the "reference_le.pfm" file
HdrImages.set_pixel(img,0+1, 0+1, ColorTypes.RGB(1.0e1, 2.0e1, 3.0e1))
HdrImages.set_pixel(img,1+1, 0+1, ColorTypes.RGB(4.0e1, 5.0e1, 6.0e1))
HdrImages.set_pixel(img,2+1, 0+1, ColorTypes.RGB(7.0e1, 8.0e1, 9.0e1))
HdrImages.set_pixel(img,0+1, 1+1, ColorTypes.RGB(1.0e2, 2.0e2, 3.0e2))
HdrImages.set_pixel(img,1+1, 1+1, ColorTypes.RGB(4.0e2, 5.0e2, 6.0e2))
HdrImages.set_pixel(img,2+1, 1+1, ColorTypes.RGB(7.0e2, 8.0e2, 9.0e2))

# This is the content of "reference_le.pfm" (little-endian file)
reference_bytes = [
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
]

buf = IOBuffer()
write(buf,img)

@testset "HdrImage Save Method" begin
    @test take!(buf) == reference_bytes
end
