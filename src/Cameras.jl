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

"""
struct ImageTracer
    image::HdrImage
    camera::Camera
end

function fire_ray(im::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)
    u = (col -1 + u_pixel)/(im.image.width)
    v = 1.0 - (row -1 + v_pixel)/(im.image.height)
    return fire_ray(im.camera, u, v)
end

"""
    fire_all_rays(im, func)

It fires all rays, requiring a ImageTracer and a generic function (to assign colors to the pixels).
"""
function fire_all_rays(im::ImageTracer, func, renderer::Renderer)
    temp = 100
    for row ∈ 1:im.image.height
           percentage= convert(Int,floor(100*(row-1)/im.image.height))
           if percentage != temp
                print("\rComputed $percentage% of pixels \n")
                temp = percentage
            end
            for col ∈ 1:im.image.width
#            println("($row, $col)")
                ray = fire_ray(im, col, row)
                # if col==3 && row==6
                # println(ray)
                # end
                color = func(ray, renderer)
            im.image.pixels[get_pixel(im.image, col, row)] = color
        end
    end
end

function fire_all_rays(im::ImageTracer, func)
#    println(" ")
    for row ∈ 1:im.image.height
#        percentage=convert(Int64, 100*row/im.image.height) 
#        println("\r")
#        println("Computed $percentage% of pixels")
        for col ∈ 1:im.image.width
            ray = fire_ray(im, col, row)
            color = func(ray)
            im.image.pixels[get_pixel(im.image, col, row)] = color
        end
    end
end
