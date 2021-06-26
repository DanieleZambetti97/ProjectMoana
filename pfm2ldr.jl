import Pkg
Pkg.activate(normpath(@__DIR__))

import ProjectMoana: HdrImage, read_pfm_image, normalize_image, clamp_image, greet
import Images: save
using ArgParse

function parse_commandline()
    s = ArgParseSettings(description = "This program converts a PFM image into a PNG image. Try me!",
                               usage = "usage: [--help] [--file_in FILE_IN] [--a] [--clamp CLAMP] [--file_out FILE_OUT]",
                              epilog = "Let's try again!")

    @add_arg_table s begin
        "--file_in"
            help = "input PFM file name;"
            required = true
        "--a"
            help = "a_factor;"
            required = false
            default = 1.
            arg_type = Float64
        "--clamp"
            help = "specify which clamping to use: Custom (C) or ImageMagick (IM);"
            default = "C"
        "--file_out"
            help = "output LDR file name (with extension)."
            required = false
            default = "LDR_out.png"
    end

    return parse_args(s)
end

function main()
    # greet()
    params = parse_commandline()

# firtsly, open the input file
    img = HdrImage(1, 1)
    open(params["file_in"], "r") do inpf
        img = read_pfm_image(inpf)
    end
    
    println("File $(params["file_in"]) has been read from disk.") # check

# then normalizing and clamping

    if params["clamp"] == "C"
        normalize_image(img, params["a"])
        clamp_image(img)
    end

# saving the image in the output format using Images method

    image = reshape(img.pixels, (img.width,img.height))
    
    save("$(params["file_out"])",image')

    println("File $(params["file_out"]) has been written to disk.") # check
    
end

main()
