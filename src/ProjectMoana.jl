module ProjectMoana

export printcol, luminosity

export HdrImage, InvalidPfmFileFormat, 
       _parse_img_size, _parse_endianness, _read_float, _read_line,
       valid_coordinates, pixel_offset, get_pixel, set_pixel,
       average_luminosity, clamp_image, normalize_image, read_pfm_image

export Vec, Point, Transformation, Normal, Vec2D,
       cross, squared_norm, norm, normalize, inverse, is_consistent, toVec,
       translation, scaling, rotation_x, rotation_y, rotation_z

export Camera, OrthogonalCamera, PerspectiveCamera, Ray, ImageTracer,
       at, fire_ray, fire_all_rays

export Shape, Sphere, World, Plane, HitRecord, ray_intersection, add_shape

export Material, BRDF, Pigment 

include("RaytracerColors.jl")
include("HdrImages.jl")
include("Geometry.jl")
include("Cameras.jl")
include("Shape.jl")
include("PathTracer.jl")

greet(name) = println("Hello $(name)! Moana welcomes you!")
greet() = println("Hello User! Moana welcomes you!")

end # module
