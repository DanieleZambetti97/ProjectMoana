import Pkg
Pkg.activate(normpath(@__DIR__))

import ProjectMoana: HdrImage, read_pfm_image, normalize_image, clamp_image, greet
using ArgParse
using Images

function parse_commandline()
    s = ArgParseSettings(description = "This program converts a PFM image into a PNG image. Try me!",
                               usage = "usage: [--help] [IN_FILE] [A_FACTOR] [γ] [OUT_FILE]")

    @add_arg_table s begin
        "IN_FILE"
            help = "input PFM file name"
            required = true
        "A_FACTOR"
            help = "a_factor"
            required = false
            default = 0.18
            arg_type = Float64
        "γ"
            help = "γ factor"
            required = false
            default = 1.0
            arg_type = Float64
        "OUT_FILE"
            help = "output PNG file name"
            required = false
            default = "out.png"
    end

    return parse_args(s)
end

function main()
    greet()
    params = parse_commandline()

# firtsly, open the input file
    img = HdrImage(1, 1)
    open(params["IN_FILE"], "r") do inpf
        img = read_pfm_image(inpf)
    end
    
    println("File $(params["IN_FILE"]) has been read correctly from disk.") # check

# then normalizing and clamping

    normalize_image(img, params["A_FACTOR"])
    clamp_image(img)  
  
    # image = [RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0);
    #          RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0) RGB(1.0,0.0,0.0)]
    image = reshape(img.pixels, (img.height,img.width))
    
    Images.save("$(params["OUT_FILE"])",image)

    # open(params["OUT_FILE"], "w") do outf
    #     write_ldr_image(img, stream=outf, format="PNG", γ = params["γ"])
    # end

    println("File $(params["OUT_FILE"]) has been written correctly to disk.") # check
    
end

main()
