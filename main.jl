import Pkg
Pkg.activate(normpath(@__DIR__))

using ArgParse
import ProjectMoana: greet

# function main()
#     greet()
# end
# main()

function parse_commandline()
    s = ArgParseSettings()

    input_pfm_file_name: str = ""
    factor:float = 0.2
    gamma:float = 1.0
    output_png_file_name: str = ""

    @add_arg_table s begin
        "arg1"
            help = "input PFM file name"
            required = true
        "arg2"
            help = "a_factor"
            required = true
            default = 0.18
            arg_type = Float64
        "arg3"
            help = "gamma factor"
            required = true
            default = 1.0
            arg_type = Float64
        "arg4"
            help = "output PNG file name"
            required = true
            default = "out.png"
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
end

main()