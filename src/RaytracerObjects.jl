import ProjectMoana: Point, Vec, HdrImage
import Base.:≈

export Ray, at, fire_all_rays, fire_ray

"""
This Struct creates a **Ray**. Its constructor takes a origin point (Point type) and a direction vector (Vec type).
"""
struct Ray
    origin::Point 
    dir::Vec      
    tmin::Float64
    tmax::Float64 
    depth::Int16
    
    Ray(origin, dir) = new(origin, dir, 1e-5, Inf, 0) 
end

# at method
at(ray::Ray, t::Float64) = ray.origin + ray.dir*t

# approx method for testing Ray
Base.:isapprox(ray1::Ray, ray2::Ray) = Base.isapprox(ray1.origin, ray2.origin) && Base.isapprox(ray1.dir, ray2.dir)

"""
This struct create a **ImageTracer**. Its constructor takes a raster image (HdrImage) and a camera.
"""
struct ImageTracer
    image::HdrImage
    camera::Camera

    ImageTracer(image, camera) = new(image, camera)
end

function fire_ray(im::ImageTracer, col, row, u_pixel::Float64=0.5, v_pixel::Float64=0.5) 
    u = (col + u_pixel)/(im.image.width - 1)
    v = (col + v_pixel)/(im.image.height - 1)
    return fire_ray(im.camera, u, v)
end

function fire_all_rays(im::ImageTracer, func)
    for row ∈ 1:im.image.height
        for col ∈ 1:im.image.width
            ray = fire_ray(im, col, row)
            color = func(ray)
            im.image.set_pixel(col, row, color)
        end
    end
end


