import Pkg
Pkg.activate(normpath(@__DIR__))

using ProjectMoana
using ArgParse
import Images: save
import Base: write  
import ColorTypes: RGB


function parse_commandline()
    s = ArgParseSettings(
        description = "This program generates an image reading a scene from a input file. Try me!",
        usage = "usage: [--help] [--scene SCENE_FILE] [--alg RENDER_ALG] [--seq S] [--pix_rays RAYS_PER_PIXEL] 
        [--rays NUM_OF_RAYS] [--d DEPTH] [--rr RUSSIAN_ROULETTE] [--file_out FILENAME] ",
        epilog = "Let's try again!"
        )

    @add_arg_table s begin
        "--scene"
            help = "name of the input scene file;"
            required = false
            default = "scene1.txt"
            arg_type = String    
        "--alg"
            help = "type of rendering algorithm (O for On-Off, F for Flat, P for Path Tracer);"
            required = false
            default = "P" 
            arg_type = String  
        "--seq"
            help = "sequence number for PCG generator;"
            required = false
            default = 54
            arg_type = Int
        "--pix_rays"
            help = "number of rays per pixel for antialasing;"
            required = false
            default = 4
            arg_type = Int
        "--rays"
            help = "number of rays fired per intersection;"
            required = false
            default = 2
            arg_type = Int
        "--d"
            help = "max depth at which the intersection are evaluated;"
            required = false
            default = 3
            arg_type = Int
        "--rr"
            help = "russian roulette limit value;"
            required = false
            default = 2
            arg_type = Int
        "--file_out"
            help = "name of the output file (without extension)."
            required = false
            default = "demo_out" 
            arg_type = String  
    end

    return parse_args(s)
end

function build_variable_table(definitions::String)

    variables = Dict{String, Float32}()

    if definitions == "€" ######default option, return empty dictionary
        return variables
    end

    for declaration in definitions
        parts = split(declaration, ":")
        if length(parts) != 2
            println("error, the definition «$declaration» does not follow the pattern NAME:VALUE")
            exit(1)
        end

        name, value = parts
        try
            value = Float32(value)
        catch e
            println("invalid floating-point value «$value» in definition «$declaration»")

        variables[name] = value
        end
    end

    return variables
end

function main()

# Initialize command line args 
    params = parse_commandline()

    ## AGGIUNGERE W E H!
    file_out_pfm = "$(params["file_out"]).pfm"
    file_out_png = "$(params["file_out"]).png"
    algorithm = params["alg"]
    seq = convert(UInt64, params["seq"])
    scene_file = params["scene"]
    samples_per_pixel = params["pix_rays"]
    n_rays = params["rays"]
    depth = params["d"]
    russ_roulette = params["rr"]

    variables = build_variable_table("") # animation variable, if you want

    samples_per_side = sqrt(samples_per_pixel)
    if samples_per_side^2 != samples_per_pixel
        println("Error, the number of rays per pixel ($samples_per_pixel) must be a perfect square")
        return
    end

# Parsing scene file
    println("Reading $scene_file")
    input_file = open(scene_file, "r")
    scene = parse_scene(InputStream(input_file,SourceLocation(scene_file)), variables)
    println("Observer's Camera and World objects created.")

# Creating an ImageTracer object 
    image = HdrImage(w, h)
    println("Generating a $w×$h image")
    tracer = ImageTracer(image, scene.camera, samples_per_pixel)

# Computing ray intersection
    print("Computing ray intersections ")
    if algorithm == "F"
        println("using Flat algorithm")
        renderer = Flat_Renderer(scene.world, RGB(0.4f0,0.4f0,0.4f0))
        fire_all_rays(tracer, Flat, renderer)
    elseif algorithm == "P"
        println("using Path Tracer algorithm")
        renderer = PathTracer_Renderer(scene.world; background_color=RGB(0.f0,0.f0,0.f0), pcg=PCG(UInt64(42), seq),
                                       num_of_rays = n_rays, max_depth = depth, russian_roulette_limit = russ_roulette)
        fire_all_rays(tracer, PathTracer, renderer)
    else
        println("using On/Off algorithm")
        renderer = OnOff_Renderer(scene.world)
        fire_all_rays(tracer, OnOff, renderer)
    end
    println("\nRay intersections evaluated.")


# Saving the PFM FILE 
    write(file_out_pfm, tracer.image)
    println("$(file_out_pfm) has been written to disk.")
      
end


main()