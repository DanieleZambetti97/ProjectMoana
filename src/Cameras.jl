export Camera, OrthogonalCamera, PerspectiveCamera, Ray, at, fire_ray, fire_all_rays, ImageTracer

## Code for RAYS #########################################################################################################################

"""
    Ray(origin, dir)
    Ray(origin, dir, tmin) 
    Ray(origin, dir, tmin, tmax)
    Ray(origin, dir, tmin, tmax, depth)

It creates a **Ray**. When not specified in the constructor, tmin = 1e-5, tmax = +∞ and depth = 0.
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

Base.:isapprox(ray1::Ray, ray2::Ray) = Base.isapprox(ray1.origin, ray2.origin) && Base.isapprox(ray1.dir, ray2.dir)

"""
    at(ray, t)

It calculates the position of the ray at the instant *t*.
"""
at(ray::Ray, t::Number) = ray.origin + ray.dir*t



## Code for the CAMERAS #################################################################################################################

# Camera is the abstract type which the two different cameras are generated from. 
abstract type Camera
end

"""
    OrthogonalCamera(a, T)
    OrthogonalCamera(a)
    OrthogonalCamera(T)
    OrthogonalCamera()

It creates a **Orthogonal Camera**. 

## Arguments:
- *a* -> aspect ratio;
- *T* -> generic Transformation.

When not specified in the constructor, a = 1 and T = Transformation(), 
where *a* is the aspect ratio and *T* a generic transformation.
"""
struct OrthogonalCamera <: Camera
    aspect_ratio::Float64
    transformation::Transformation

    OrthogonalCamera(a, T) = new(a, T)
    OrthogonalCamera(a::Float64) = new(a, Transformation() )
    OrthogonalCamera(T::Transformation) = new(1.0, T )
    OrthogonalCamera() = new( 1.0, Transformation() )

end

"""
#### Usage 1:
    fire_ray(camera, u, v)

It fires a ray from a camera (Orthogonal or Perspective) directed to a pixel with coordinates *u* and *v* (on the screen).

## Usage 2:
    fire_ray(im, col, row, u_pixel, v_pixel)

It fires a ray from a camera (contained in *im*) directed to (col, row)-pixel. It hits the pixel in hte point with coordinates 
*u_pixel*, *v_pixel*.

## Arguments:
- *im* -> object of type ImageTracer;
- *col* & *row* -> integers for the coordinates of the pixel in the raster image;
- *u_pixel* and *v_pixel* -> integers for the coordinates inside the pixel.

If not specified *u_pixel* = *v_pixel* = 0.5.

"""
function fire_ray( camera::OrthogonalCamera, u, v)
    Ray_StandardFrame = Ray( Point(-1.0, (1.0-2*u)*camera.aspect_ratio, 2*v-1), Vec(1.0, 0.0, 0.0), 1.0 )
    return camera.transformation * Ray_StandardFrame
end

"""
    PerspectiveCamera(a, T, d)
    PerspectiveCamera(a, T)
    PerspectiveCamera(a)
    PerspectiveCamera()

It creates a **Perspective Camera**. 

## Arguments:
- *a* -> aspect ratio;
- *T* -> generic Transformation;
- *d* -> distance between the observer and the screen(?).

When not specified in the constructor, a = 1 and T = Transformation(), 
where *a* is the aspect ratio and *T* a generic transformation.
"""
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
    Ray_StandardFrame = Ray( Point(-camera.distance, 0.0, 0.0), Vec(camera.distance, (1.0-2*u)*camera.aspect_ratio, 2*v-1), 1.0)
    return camera.transformation * Ray_StandardFrame
end


## Defining IMAGETRACER and its methods: fire_ray and fire_all_rays: ##################################################################à

"""
    ImageTracer()

It creates a **ImageTracer**. 
    
## Arguments:
- image -> object of type HdrImage;
- camera.

"""
struct ImageTracer
    image::HdrImage
    camera::Camera
end

function fire_ray(im::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)
    u = (col + u_pixel)/(im.image.width)
    v = 1.0 - (row + v_pixel)/(im.image.height)
    return fire_ray(im.camera, u, v)
end

"""
    fire_all_rays(im, func)

It fires all rays, requiring a ImageTracer and a generic function (to assign colors to the pixels).
"""
function fire_all_rays(im::ImageTracer, func)
    for row ∈ 1:im.image.height
        for col ∈ 1:im.image.width
            ray = fire_ray(im, col, row)
            color = func(ray)
            im.image.pixels[get_pixel(im.image, col, row)] = color
        end
    end
end
