import Pkg
Pkg.activate(normpath(@__DIR__))

using ArgParse
import ProjectMoana: greet
import ProjectMoana: HdrImage, read_pfm_image, normalize_image, clamp_image

function parse_commandline()
    s = ArgParseSettings()

    input_pfm_file_name: str = ""
    factor:float = 0.2
    gamma:float = 1.0
    output_png_file_name: str = ""

    @add_arg_table s begin
        "in_file"
            help = "input PFM file name"
            required = true
        "a_factor"
            help = "a_factor"
            required = true
            default = 0.18
            arg_type = Float64
        "gamma"
            help = "gamma factor"
            required = true
            default = 1.0
            arg_type = Float64
        "out_file"
            help = "output PNG file name"
            required = true
            default = "out.png"
    end

    return parse_args(s)
end

function main()
    greet()
    params = parse_commandline()

# firtsly, open the input file
    img = HdrImage(1, 1)
    open(params["in_file"], "r") do inpf
        img = read_pfm_image(inpf)
    end
    
    println("File $(params["in_file"]) has been read correctly from disk.") # check

# normalizing and clamping

    normalize_image(img, params["a_factor"])
    clamp_image(img)

    # open(params["out_file"], "w") do outf
    #     write_ldr_image(img, stream=outf, format="PNG", gamma=parameters.gamma)
    # end

    # print(f"File {parameters.output_png_file_name} has been written to disk.") # check
    
end

main()