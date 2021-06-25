import Pkg
Pkg.activate(normpath(@__DIR__))

import ProjectMoana: HdrImage, read_pfm_image, normalize_image, clamp_image, greet
import Images: save
using ArgParse

function parse_commandline()
    s = ArgParseSettings(description = "This program converts a PFM image into a PNG image. Try me!",
                               usage = "usage: [--help] [--in_file IN_FILE] [--a] [--γ] [--out_file OUT_FILE]",
                              epilog = "Let's try again!")

    @add_arg_table s begin
        "--in_file"
            help = "input PFM file name"
            required = true
        "--a"
            help = "a_factor"
            required = false
            default = 1.
            arg_type = Float64
        "--γ"
            help = "γ factor"
            required = false
            default = 1.0
            arg_type = Float64
        "--out_file"
            help = "output LDR file name"
            required = false
            default = "out.png"
    end

    return parse_args(s)
end

function main()
    # greet()
    params = parse_commandline()

# firtsly, open the input file
    img = HdrImage(1, 1)
    open(params["in_file"], "r") do inpf
        img = read_pfm_image(inpf)
    end
    
    println("File $(params["in_file"]) has been read from disk.") # check

# then normalizing and clamping

    normalize_image(img, params["a"])
    clamp_image(img)

# saving the image in the output format using Images method

    image = reshape(img.pixels, (img.width,img.height))
    
    save("$(params["out_file"])",image')

    println("File $(params["out_file"]) has been written to disk.") # check
    
end

main()
