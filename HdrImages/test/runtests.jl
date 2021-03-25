using ImportMacros
using Test
include("../../RaytracerColors/src/RaytracerColors.jl")
@import HdrImages as Hdr
@import ColorTypes as CT

# TESTING THE BASIC METHODS FOR HdrImages 

img = Hdr.HdrImage(3, 2)

@testset "HdrImage Basic Methods" begin
    @test img.width == 3
    @test img.height == 2
    @test Hdr.valid_coordinates(img, 2, 1) == true
    @test Hdr.valid_coordinates(img, 3, 2) == true #the last element of the matrix has to be (3,2) and not (2,1) as in C++
    @test Hdr.valid_coordinates(img,-1, 4) == false
    @test Hdr.valid_coordinates(img, 0, 4) == false
    @test Hdr.pixel_offset(img,1,1) == 1
    @test Hdr.pixel_offset(img,2,2) == 5
    @test Hdr.get_pixel(img, 1, 2) == 4
    @test Hdr.get_pixel(img, 3, 1) == 3 

new_col = CT.RGB(.012, 34, 999.9)
Hdr.set_pixel(img, 1, 1, new_col)
Hdr.set_pixel(img, 3, 2, new_col)

    @test img.pixels[1] == new_col
    @test img.pixels[Hdr.get_pixel(img, 3, 2)] == new_col
    
end

# TESTING THE WRITING/READING METHODS FOR HdrImages 

# Set pixels colors like the "reference_le.pfm" file
Hdr.set_pixel(img,0+1, 0+1, CT.RGB(1.0e1, 2.0e1, 3.0e1))
Hdr.set_pixel(img,1+1, 0+1, CT.RGB(4.0e1, 5.0e1, 6.0e1))
Hdr.set_pixel(img,2+1, 0+1, CT.RGB(7.0e1, 8.0e1, 9.0e1))
Hdr.set_pixel(img,0+1, 1+1, CT.RGB(1.0e2, 2.0e2, 3.0e2))
Hdr.set_pixel(img,1+1, 1+1, CT.RGB(4.0e2, 5.0e2, 6.0e2))
Hdr.set_pixel(img,2+1, 1+1, CT.RGB(7.0e2, 8.0e2, 9.0e2))

# This is the content of "reference_le.pfm" (little-endian file)
LE_REFERENCE_BYTES = [
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
]

# Test the write function
buf = IOBuffer()
write(buf,img)

@testset "HdrImages Writing Method" begin
    @test take!(buf) == LE_REFERENCE_BYTES
end

# Test the read function
line = IOBuffer(b"Hello\nWorld!")

@testset "HdrImages Reading Method" begin

<<<<<<< HEAD
    #1
    @test Hdr.read_line(line) == "Hello"
    @test Hdr.read_line(line) == "World!"
    @test Hdr.read_line(line) == ""    
=======
    # read_line
    @test Hdr._read_line(line) == "Hello"
    @test Hdr._read_line(line) == "World!"
    @test Hdr._read_line(line) == ""    
>>>>>>> f2f9e888737071fe2082f875a8d4ca0dff2b9c1e
    
    #3
    @test Hdr._parse_img_size("3 2") == (3, 2)
    @test_throws Hdr.InvalidPfmFileFormat Hdr._parse_img_size("-1 3")
    @test_throws Hdr.InvalidPfmFileFormat Hdr._parse_img_size("1 2 3") 

    #4
    @test Hdr._parse_endianness("1.0") == "BE"
    @test Hdr._parse_endianness("-1.0") == "LE"
    @test_throws Hdr.InvalidPfmFileFormat Hdr._parse_endianness("abc")
    @test_throws Hdr.InvalidPfmFileFormat Hdr._parse_endianness("2.0")
end


# This is the content of "reference_be.pfm" (big-endian file)
BE_REFERENCE_BYTES = [
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
]

    for reference_bytes in [LE_REFERENCE_BYTES, BE_REFERENCE_BYTES]
        img2 = read(IOBuffer(reference_bytes))

        @test img2.pixels[get_pixel(img2, 0+1, 0+1)] ≈ CT.RGB(1.0e1, 2.0e1, 3.0e1)
        @test img2.pixels[get_pixel(img2, 1+1, 0+1)] ≈ CT.RGB(4.0e1, 5.0e1, 6.0e1)
        @test img2.pixels[get_pixel(img2, 2+1, 0+1)] ≈ CT.RGB(7.0e1, 8.0e1, 9.0e1)
        @test img2.pixels[get_pixel(img2, 0+1, 1+1)] ≈ CT.RGB(1.0e2, 2.0e2, 3.0e2)
        @test img2.pixels[get_pixel(img2, 0+1, 0+1)] ≈ CT.RGB(1.0e1, 2.0e1, 3.0e1)
        @test img2.pixels[get_pixel(img2, 1+1, 1+1)] ≈ CT.RGB(4.0e2, 5.0e2, 6.0e2)
        @test img2.pixels[get_pixel(img2, 2+1, 1+1)] ≈ CT.RGB(7.0e2, 8.0e2, 9.0e2)
    end

    buf = BytesIO(b"PF\n3 2\n-1.0\nstop")
        @test_throws Hdr.InvalidPfmFileFormat read(buf)