module HdrImages

import Colors
import ColorTypes
import Base

greet() = print("Hello World!")

mutable struct HdrImage
    width::Int
    height::Int
    pixels::Array{ColorTypes.RGB, 1}
    HdrImage(w, h) = new(w, h, [ColorTypes.RGB() for i in 1:h*w]) #incredibile, se implementi un costruttore interno julia rimuove il suo 
    HdrImage(w, h, array) = new(w, h, array)                      #costruttore di default quindi devi rimplementarlo te
end


# Check if the coordinates pass are valid
valid_coordinates(img::HdrImage, x, y) = return((x > 0) && (x <= img.width) && (y >= 0) && (y <= img.height))


# Check that the (x,y) pixel of the image is in the right place in the linear array pixels of the struct
pixel_offset(img::HdrImage, x, y) = (y-1) * img.width + x


# Get and set methods
get_pixel(img::HdrImage, x, y) = HdrImages.valid_coordinates(img, x, y) && return(HdrImages.pixel_offset(img, x, y)) 

set_pixel(img::HdrImage, x, y, new_color::ColorTypes.RGB) = HdrImages.valid_coordinates(img, x, y) && (img.pixels[HdrImages.get_pixel(img, x, y)] = new_color)


# Save an HdrImage on a file in PFM format
const little_endian = ENDIAN_BOM
function write_pfm(io::IO, img:: HdrImage)
    write(io, transcode(UInt8, "PF\n$(img.width) $(img.height)\n-1.0\n"))
#=     # Write the image (bottom-to-up, left-to-right)
    for y in img.height:1
        for x in 1:img.width
            color = img.get_pixel(x, y)
            write(io, reinterpret(UInt32, color.r))
            write(io, reinterpret(UInt32, color.g))
            write(io, reinterpret(UInt32, color.b))
        end
    end
 =#end

Base.:write(io::IO , img::HdrImage) = write(io, transcode(UInt8, "PF\n$(img.width) $(img.height)\n$little_endian\n"))


end # module
