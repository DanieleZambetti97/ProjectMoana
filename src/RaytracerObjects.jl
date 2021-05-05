export Camera, OrthogonalCamera, PerspectiveCamera, Ray, at, fire_ray, fire_all_rays, ImageTracer


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
    Ray(origin, dir, tmin) = new(origin, dir, tmin, Inf, 0)
    Ray(origin, dir, tmin, tmax) = new(origin, dir, tmin, tmax, 0)
    Ray(origin, dir, tmin, tmax, depth) = new(origin, dir, tmin, tmax, depth)

end

Base.:*(T::Transformation, R::Ray) = Ray(T*R.origin, T*R.dir, R.tmin, R.tmax, R.depth )

abstract type Camera
end

struct OrthogonalCamera <: Camera
    aspect_ratio::Float64
    transformation::Transformation

    OrthogonalCamera(a, T) = new(a, T)
    OrthogonalCamera(a::Float64) = new(a, Transformation() )
    OrthogonalCamera(T::Transformation) = new(1.0, T )
    OrthogonalCamera() = new( 1.0, Transformation() )

end
function fire_ray( camera::OrthogonalCamera, u, v)
    Ray_StandardFrame = Ray( Point(-1.0, (1.0-2*u)*camera.aspect_ratio, 2*v-1), Vec(1.0, 0.0, 0.0), 1.0 )
    return camera.transformation * Ray_StandardFrame
end

struct PerspectiveCamera <: Camera
    aspect_ratio::Float64
    transformation::Transformation
    distance::Float64

    PerspectiveCamera(a, T, d) = new(a, T, d )
    PerspectiveCamera(a, T) = new(a, T, 1.0 )
    PerspectiveCamera(a) = new(a, Transformation(), 1.0 )
    PerspectiveCamera() = new(1.0, Transformation(), 1.0 )  
end

function fire_ray(camera::PerspectiveCamera, u, v)
    Ray_StandardFrame = Ray( Point(-camera.distance, 0.0, 0.0), Vec(camera.distance, (1.0-2*u)*camera.aspect_ratio, 2*v-1), 1.0 )
    return camera.transformation * Ray_StandardFrame
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
end

function fire_ray(im::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)
    u = (col + u_pixel)/(im.image.width)
    v = (row + v_pixel)/(im.image.height)
    return fire_ray(im.camera, u, v)
end

function fire_all_rays(im::ImageTracer, func)
    for row ∈ 1:im.image.height
        for col ∈ 1:im.image.width
            ray = fire_ray(im, col, row)
            color = func(ray)
            im.image.pixels[get_pixel(im.image, col, row)] = color
        end
    end
end
