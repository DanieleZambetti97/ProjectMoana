module HdrImages

using ImportMacros
import Colors
import Base
using ColorTypes


greet() = print("Hello World!")

###################################################################################################################
# creating HdrImage 

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


################################################################################################################
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

######################################################################################################
# Read an HdrImage in PMF format from a file
# new error message InvalidPfmFileFormat

struct InvalidPfmFileFormat <: Exception
    msg::String
    
    function InvalidPfmFileFormat(msg::String)
        new(msg)
    end
end

# Support function for read_pfm_image

function _read_line(stream::IO)
    result = ""
    while true
        cur_byte = read(stream, 1)
        if cur_byte == transcode(UInt8, "") || cur_byte == transcode(UInt8, "\n")
            return result
        end
        result *= transcode(String, cur_byte)
    end
end

function _read_float(io::IO, endianness::String)
    if endianness == "LE"
        return transcode(String, ltoh(read(io, 4)))
    else
        return transcode(String, ntoh(read(io, 4)))
    end
end

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

function _parse_endianness(line::String)
    value = 0
    try
        value = parse(Float32, line)
    catch e
        throw(InvalidPfmFileFormat("missing endianness specification"))
    end

    if value == 1.0
        return "BE"
    elseif value == -1.0
        return "LE"
    else
        throw(InvalidPfmFileFormat("invalid endianness specification"))
    end
end

# finally, the real READING method:
function Base.read(io::IO)
   
    magic = HdrImages._read_line(fname)
    if magic != "PF"
    throw(InvalidPfmFileFormat("invalid magic in PFM file"))
    end

    img_size = HdrImages._read_line(fname)
    (width, height) = HdrImages._parse_img_size(img_size)

    endianness_line = HdrImages._read_line(fname)
    endianness = HdrImages._parse_endianness(endianness_line)

    result = HdrImage(width, height)
    for y in height:-1:1
        for x in 1:width                
            (r, g, b) = [HdrImages._read_float(fname, endianness) for i in 1:3]
            result.set_pixel(x, y, Color(r, g, b))
        end
    end

    return result

end

function Base.read(filein::String)
    io = open(filein, "r")
    read(io)
end


end # module
