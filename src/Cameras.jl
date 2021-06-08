## Code for the CAMERAS #################################################################################################################

abstract type Renderer end 

# Camera is the abstract type which the two different cameras are generated from. 

abstract type Camera
end

"""
    OrthogonalCamera( aspect_ratio=1.0, transformation=Transformation())

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

    OrthogonalCamera( aspect_ratio=1.0, transformation=Transformation()) = new(aspect_ratio, transformation)
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
    Ray_StandardFrame = Ray( Point(-1.0, (1.0-2*u)*camera.aspect_ratio, 2*v-1), Vec(1.0, 0.0, 0.0))
    return camera.transformation * Ray_StandardFrame
end

"""
    PerspectiveCamera(;a=1.0, T=Transformation(), d=1.0)

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

    PerspectiveCamera(aspect_ratio=1.0, transformation=Transformation(), distance=1.0) = new(aspect_ratio, transformation, distance )
#    PerspectiveCamera(transformation=Transformation(), distance=1.0) = new(1.0, transformation, distance )
end

function fire_ray(camera::PerspectiveCamera, u, v)
    Ray_StandardFrame = Ray( Point(-camera.distance, 0.0, 0.0), Vec(camera.distance, (1.0-2*u)*camera.aspect_ratio, 2*v-1))
    return camera.transformation * Ray_StandardFrame
end


## Defining IMAGETRACER and its methods: fire_ray and fire_all_rays: ##################################################################à

"""
    ImageTracer()

It creates a **ImageTracer**. 
    
## Arguments:
- image -> object of type HdrImage;
- camera.
- ray_per_side^2 is the number of ray that are trow for each pixels to reduce aliasing

"""
struct ImageTracer
    image::HdrImage
    camera::Camera
    ray_per_side::Int
    pcg::PCG

    ImageTracer(image::HdrImage, camera::Camera, ray_per_side::Int=1, pcg::PCG=PCG()) = new(image, camera, ray_per_side, pcg)
end

function fire_ray(im::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)
    ray_vector = []
    for i in 1:im.ray_per_side
        for j in 1:im.ray_per_side
            if im.ray_per_side > 1
                u_pixel = (j - 1 + pcg_randf(im.pcg)) / im.ray_per_side
                v_pixel = (i - 1 + pcg_randf(im.pcg)) / im.ray_per_side
            end
            u = (col -1 + u_pixel)/(im.image.width)
            v = 1.0 - (row -1 + v_pixel)/(im.image.height)
            ray = fire_ray(im.camera, u, v)
            push!(ray_vector, ray)
        end
    end
    return ray_vector 
end

"""
    fire_all_rays(im, func)

It fires all rays, requiring a ImageTracer and a generic function (to assign colors to the pixels).
"""
function fire_all_rays(im::ImageTracer, func, renderer::Renderer)
    temp = -2
    for row ∈ 1:im.image.height
        for col ∈ 1:im.image.width
            cum_color = RGB(0.,0.,0.)
            rays_in_pixel= fire_ray(im, col, row)

            for ray in rays_in_pixel
                cum_color += func(ray, renderer)
            end

            im.image.pixels[get_pixel(im.image, col, row)] = cum_color * (1. / im.ray_per_side^2)
        end

        percentage= convert(Int,floor(100*(row-1)/im.image.height)) ##print progress
        if percentage == temp+2
            i = convert(Int,floor(percentage/2))
            print("\rComputed $(percentage)% of pixels [$("#"^i)$("."^(49-i))]")
            temp = percentage
        end

    end
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
