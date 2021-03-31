using ProjectMoana
# TESTING THE BASIC METHODS FOR HdrImages #######################################################################################

img = HdrImage(3, 2)

@testset "HdrImages Basic Methods " begin
    @test img.width == 3
    @test img.height == 2
    @test valid_coordinates(img, 2, 1) == true
    @test valid_coordinates(img, 3, 2) == true #the last element of the matrix has to be (3,2) and not (2,1) as in C++
    @test valid_coordinates(img,-1, 4) == false
    @test valid_coordinates(img, 0, 4) == false
    @test pixel_offset(img,1,1) == 1
    @test pixel_offset(img,2,2) == 5
    @test get_pixel(img, 1, 2) == 4
    @test get_pixel(img, 3, 1) == 3 

new_col = RGB(.012, 34, 999.9)
set_pixel(img, 1, 1, new_col)
set_pixel(img, 3, 2, new_col)

    @test img.pixels[1] == new_col
    @test img.pixels[get_pixel(img, 3, 2)] == new_col
    
end

# TESTING THE WRITING/READING METHODS FOR HdrImages ############################################################################

img2 = HdrImage(3, 2)

LE_REFERENCE_BYTES = [
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
]

BE_REFERENCE_BYTES = [
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
]
# Set pixels colors like the "reference_le.pfm" file
set_pixel(img2,1, 1, RGB(1.0e1, 2.0e1, 3.0e1))
set_pixel(img2,2, 1, RGB(4.0e1, 5.0e1, 6.0e1))
set_pixel(img2,3, 1, RGB(7.0e1, 8.0e1, 9.0e1))
set_pixel(img2,1, 2, RGB(1.0e2, 2.0e2, 3.0e2))
set_pixel(img2,2, 2, RGB(4.0e2, 5.0e2, 6.0e2))
set_pixel(img2,3, 2, RGB(7.0e2, 8.0e2, 9.0e2))

# Test the write function
buf = IOBuffer()
write(buf,img2)

@testset "HdrImages Writing Method" begin
    @test take!(buf) == LE_REFERENCE_BYTES
end

# Test the read function
line = IOBuffer(b"Hello\nWorld!")

@testset "HdrImages Reading Method" begin

    @test _read_line(line) == "Hello"
    @test _read_line(line) == "World!"
    @test _read_line(line) == ""    
    
    @test _parse_img_size("3 2") == (3, 2)
    @test_throws InvalidPfmFileFormat _parse_img_size("-1 3")
    @test_throws InvalidPfmFileFormat _parse_img_size("1 2 3") 

    @test _parse_endianness("1.0") == "BE"
    @test _parse_endianness("-1.0") == "LE"
    @test_throws InvalidPfmFileFormat _parse_endianness("abc")
    @test_throws InvalidPfmFileFormat _parse_endianness("2.0")

for reference_bytes in [ BE_REFERENCE_BYTES, LE_REFERENCE_BYTES ]
    img2_1 = read_pfm_image(IOBuffer(reference_bytes))

    @test img2.pixels[get_pixel(img2_1, 1, 1)] ≈ RGB(1.0e1, 2.0e1, 3.0e1)
    @test img2.pixels[get_pixel(img2_1, 2, 1)] ≈ RGB(4.0e1, 5.0e1, 6.0e1)
    @test img2.pixels[get_pixel(img2_1, 3, 1)] ≈ RGB(7.0e1, 8.0e1, 9.0e1)
    @test img2.pixels[get_pixel(img2_1, 1, 2)] ≈ RGB(1.0e2, 2.0e2, 3.0e2)
    @test img2.pixels[get_pixel(img2_1, 1, 1)] ≈ RGB(1.0e1, 2.0e1, 3.0e1)
    @test img2.pixels[get_pixel(img2_1, 2, 2)] ≈ RGB(4.0e2, 5.0e2, 6.0e2)
    @test img2.pixels[get_pixel(img2_1, 3, 2)] ≈ RGB(7.0e2, 8.0e2, 9.0e2)
end

buf = IOBuffer(transcode(UInt8, "PF\n3 2\n-1.0\nstop"))
    @test_throws InvalidPfmFileFormat read_pfm_image(buf)
end

# TESTING THE SAVING METHODS FOR LdrImages ############################################################################

img3 = HdrImage(2,1)

set_pixel(img3, 1, 1, RGB(5.0, 10.0, 15.0))  # Luminosity: 10.0
set_pixel(img3, 1, 2, RGB(500.0, 1000.0, 1500.0))  # Luminosity: 1000.0

println(average_luminosity(delta=0.0))
@testset "LdrImages Saving Methods" begin
    @test 100 ≈ average_luminosity(delta=0.0)
end    