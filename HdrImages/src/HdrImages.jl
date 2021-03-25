module HdrImages

import Colors
import Base
using ColorTypes


greet() = print("Hello World!")

mutable struct HdrImage
    width::Int
    height::Int
    pixels::Array{RGB, 1}
    HdrImage(w, h) = new(w, h, [RGB() for i in 1:h*w])
    HdrImage(w, h, array) = new(w, h, array)
end


# Check if the coordinates pass are valid
valid_coordinates(img::HdrImage, x, y) = return((x > 0) && (x <= img.width) && (y >= 0) && (y <= img.height))


# Check that the (x,y) pixel of the image is in the right place in the linear array pixels of the struct
pixel_offset(img::HdrImage, x, y) = (y-1) * img.width + x


# Get and set methods
get_pixel(img::HdrImage, x, y) = HdrImages.valid_coordinates(img, x, y) && return(HdrImages.pixel_offset(img, x, y)) 

set_pixel(img::HdrImage, x, y, new_color::RGB) = HdrImages.valid_coordinates(img, x, y) && (img.pixels[HdrImages.get_pixel(img, x, y)] = new_color)


# Save an HdrImage on a stream or an output file in PFM format
function Base.write(io::IO, img::HdrImage)
    header = transcode(UInt8, "PF\n$(img.width) $(img.height)\n$(-1.0)\n")
    write(io, header)

    for y in img.height:-1:1
        for x in 1:img.width

            color = img.pixels[HdrImages.get_pixel(img, x, y)]            
            write(io, convert(Vector{Float32}, [color.r,color.g,color.b] ) )

        end
    end
end

function Base.write(file_output::String, img::HdrImage)
    header = transcode(UInt8, "PF\n$(img.width) $(img.height)\n$(-1.0)\n") 
    open(file_output, "w") do io
        write(io, header)

        for y in img.height:-1:1
            for x in 1:img.width

                color = img.pixels[HdrImages.get_pixel(img, x, y)]                                         
                write(io, convert(Vector{Float32}, [color.r,color.g,color.b] ) )
                
            end
        end
    end
end

# new error message InvalidPfmFileFormat

struct InvalidPfmFileFormat <: Exception
    msg::String
    
    function InvalidPfmFileFormat(msg::String)
        new(msg)
    end
end

# lettura delle dimensioni dell’immagini da una stringa (_parse_img_size)

function _parse_img_size(line::String)
    elements = split(line, " ")
    if length(elements) != 2
        throw(InvalidPfmFileFormat("invalid image size specification!"))
    end

    (width, height) = (parse(Int, elements[1]), parse(Int, elements[2]))

                
    if (width < 0) || (height < 0)
        throw(InvalidPfmFileFormat("invalid width/size!"))
    end

return (width, height)

end


# decodifica del tipo di endianness da una stringa (_parse_endianness)

end # module
