module ProjectMoana
export PCG, pcg_init, pcg_rand, pcg_randf

export printcol, luminosity

export HdrImage, InvalidPfmFileFormat, 
       _parse_img_size, _parse_endianness, _read_float, _read_line,
       valid_coordinates, pixel_offset, get_pixel, set_pixel,
       average_luminosity, clamp_image, normalize_image, read_pfm_image, tone_mapping

export Vec, Point, Transformation, Normal, Vec2D,
       cross, squared_norm, norm, normalize, inverse, is_consistent, toVec, create_onb,
       translation, scaling, rotation_x, rotation_y, rotation_z

export BRDF, Material, Pigment, Renderer, UniformPigment, get_color, ImagePigment, CheckeredPigment, DiffuseBRDF, SpecularBRDF, scatter_ray

export Shape, Sphere, World, Plane, AAB, ShapeUnion, ShapeDifference, HitRecord, ray_intersection, add_shape, Ray, at
       
export Camera, OrthogonalCamera, PerspectiveCamera,  ImageTracer, Renderer,
       fire_ray, fire_all_rays

export  OnOff_Renderer, Flat_Renderer, PathTracer_Renderer, OnOff, Flat, PathTracer

export SourceLocation, Stop, Identifier, LiteralString, LiteralNumber, Symbol, Keyword, Token, InputStream, GrammarError, read_char, 
       unread_char, skip_whitespaces_and_comments, read_token, KeywordEnum, isdigit, NEW, MATERIAL, PLANE, SPHERE, DIFFUSE, SPECULAR, 
       UNIFORM, CHECKERED, IMAGE, IDENTITY, TRANSLATION, ROTATION_X, ROTATION_Y, ROTATION_Z, SCALING, CAMERA, ORTHOGONAL, PERSPECTIVE, 
       FLOAT, assert_is_identifier, assert_is_keyword, assert_is_number, assert_is_string, assert_is_symbol, Scene, parse_scene
      
       
using LinearAlgebra, Intervals

include("PCG.jl")
include("Colors.jl")
include("HdrImages.jl")
include("Geometry.jl")
include("Surface.jl")
include("Shape.jl")
include("Cameras.jl")
include("Renderer.jl")
include("Lexer.jl")

greet(name) = println("Hello $(name)! Moana welcomes you!")
greet() = println("Hello User! Moana welcomes you!")

end # module
