using ColorTypes

# creating HdrImage struct
"""
HdrImage(w, h; array=[RGB() for i in 1:h*w])

It creates a **HdrImage**.

## Arguments
- *width* -> integer;
- *height* -> integer;
- *pixels* -> a monodimensional array of RGB colors;

If not specified, the pixels array is this: ``[RGB() for i in 1:h*w]``.
"""
mutable struct HdrImage
    width::Int
    height::Int
    pixels::Array{RGB, 1}

    HdrImage(w, h, array=[RGB() for i in 1:h*w]) = new(w, h, array )
end

# Check if the coordinates passed are valid
valid_coordinates(img::HdrImage, x, y) = return((x > 0) && (x <= img.width) && (y >= 0) && (y <= img.height))

# Check that the (x,y) pixel of the image is in the right place in the linear array pixels of the struct
pixel_offset(img::HdrImage, x, y) = (y-1) * img.width + x


# Get and set methods

"""
    get_pixel(img, x, y)

It returns the positional index of the (x, y) pixel of the image (img).
If the coordinates are not valid it returns a Boolean.
"""
get_pixel(img::HdrImage, x, y) =  valid_coordinates(img, x, y) && return( pixel_offset(img, x, y)) 

set_pixel(img::HdrImage, x, y, new_color::RGB) =  valid_coordinates(img, x, y) && (img.pixels[ get_pixel(img, x, y)] = new_color)


## SAVING an HdrImage on a stream or an output file in PFM format ################################################################

function Base.write(io::IO, img::HdrImage)
    header = transcode(UInt8, "PF\n$(img.width) $(img.height)\n$(-1.0)\n")
    write(io, header)

    for y in img.height:-1:1
        for x in 1:img.width

            color = img.pixels[ get_pixel(img, x, y)]            
            write(io, convert(Vector{Float32}, [color.r,color.g,color.b] ) )

        end
    end
end

function Base.write(file_output::String, img::HdrImage)
    io = open(file_output, "w")
    write(io, img)
end


## READ an HdrImage in PMF format from a file #############################################################################

# new error message InvalidPfmFileFormat
struct InvalidPfmFileFormat <: Exception
    msg::String
    
    function InvalidPfmFileFormat(msg::String)
        new(msg)
    end
end

# Supporting function for read_pfm_image
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
        try 
            return ltoh(reinterpret(Float32, read(io, 4))[1])
        catch e
            throw(InvalidPfmFileFormat("impossible to read binary data from the file"))
        end
    else
        a = read(io,4)
        try 
            return ntoh(reinterpret(Float32, a)[1])     
        catch e
            throw(InvalidPfmFileFormat("impossible to read binary data from the file"))
        end
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
function read_pfm_image(io::IO)

    magic =  _read_line(io)
    if magic != "PF"
    throw(InvalidPfmFileFormat("invalid magic in PFM file"))
    end

    img_size =  _read_line(io)
    (width, height) =  _parse_img_size(img_size)

    endianness_line =  _read_line(io)
    endianness =  _parse_endianness(endianness_line)
   
    result =  HdrImage(width, height)
    for y in height:-1:1
        for x in 1:width                
            (r, g, b) = [ _read_float(io, endianness) for i in 1:3]
            set_pixel(result, x, y, RGB(r, g, b))
        end
    end

    return result
end

function read_pfm_image(filein::String)
    io = open(filein, "r")
    read_pfm_image(io)
end


## SAVE an LdrImage on an output file #############################################################################à
function average_luminosity(img::HdrImage, delta)
    sum = 0.0f0
    for pixel in img.pixels
        sum += log10(delta + luminosity(pixel))
    end
    return Float32(10^(sum/length(img.pixels)))
end

function average_luminosity(img::HdrImage)
    return average_luminosity(img, Float32(10^(-10)))
end

# Normalizing the luminosity of a image
function normalize_image(img::HdrImage, a_factor, luminosity)
   
    for i in 1:length(img.pixels)
        img.pixels[i] = img.pixels[i]::RGB * (a_factor/luminosity)::Float64
    end

end


function normalize_image(img::HdrImage, a_factor)
   
    lum = average_luminosity(img)
    normalize_image(img, a_factor, lum)

end

# clamping method
function _clamp(x)
    return x/(x+1)
end

function clamp_image(img)
    for i in 1:length(img.pixels)
        (r, g, b) = (_clamp(img.pixels[i].r), _clamp(img.pixels[i].g) , _clamp(img.pixels[i].b) )
        img.pixels[i] = RGB(r, g, b)
    end
end
