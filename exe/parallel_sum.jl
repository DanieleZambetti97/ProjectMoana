import Pkg
Pkg.activate(".")
using ProjectMoana
using ArgParse
import ColorTypes:RGB
import Images:save 

function parse_commandline()
    s = ArgParseSettings(description = "This program make an averege image from 4 images. Try me!",
                               usage = "usage: [--help] [--in_file INFILE] [--a A]",
                              epilog = "Let's try again!")

    @add_arg_table s begin
        "--in_file"
            help = "input PFM file name"
            required = true
        "--a"
            help = "a_factor for normalizing image luminosity during the convertion"
            required = false
            default = 1.
            arg_type = Float64
    end

    return parse_args(s)
end

function main()
    params = parse_commandline()

    fileinput=params["in_file"]

    img0 = read_pfm_image(string(fileinput, "000.pfm"))
    img1 = read_pfm_image(string(fileinput, "001.pfm"))
    img2 = read_pfm_image(string(fileinput, "002.pfm"))
    img3 = read_pfm_image(string(fileinput, "003.pfm"))


    out=HdrImage(img0.width,img0.height)

    for y in out.height:-1:1
        for x in 1:out.width

            color_r = (img0.pixels[ get_pixel(img0, x, y)].r + img1.pixels[ get_pixel(img1, x, y)].r + img2.pixels[ get_pixel(img2, x, y)].r + img3.pixels[ get_pixel(img3, x, y)].r) / 4.
            color_g = (img0.pixels[ get_pixel(img0, x, y)].g + img1.pixels[ get_pixel(img1, x, y)].g + img2.pixels[ get_pixel(img2, x, y)].g + img3.pixels[ get_pixel(img3, x, y)].g) / 4.
            color_b = (img0.pixels[ get_pixel(img0, x, y)].b + img1.pixels[ get_pixel(img1, x, y)].b + img2.pixels[ get_pixel(img2, x, y)].b + img3.pixels[ get_pixel(img3, x, y)].b) / 4.
            color = RGB(color_r,color_g,color_b)
            set_pixel(out, x, y, color)

        end
    end

     write(string(fileinput, "sum.pfm"), out)
     println("$(string(fileinput, "sum.pfm")) has been written to disk.")
end

main()
