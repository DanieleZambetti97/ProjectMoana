import Geometry

export Camera, OrthogonalCamera, PerspectiveCamera

struct Camera
end

struct OrthogonalCamera
    aspect_ratio::Float64
    transformation::Transformation

    OrthogonalCamera(a, T) = new(a, T)
    OrthogonalCamera(a) = new(a, Transformation() )
    OrthogonalCamera() = new( 1.0, 1.0, Transformation() )

    function fire_ray( u, v)
        Ray_StandardFrame = Ray( Point(-1.0, (1.0-2*u)*aspect_ratio, 2*v-1), Vec(1.0, 0.0, 0.0), 1.0 )
        return transformation * Ray_StandardFrame
    end

end

struct PerspectiveCamera
    aspect_ratio::Float64
    transformation::Transformation
    distance::Float64

    PerspectiveCamera(a, T, d) = new(a, T, d )
    PerspectiveCamera(a, T) = new(a, T, 1.0 )
    PerspectiveCamera(a) = new(a, Transformation(), 1.0 )
    PerspectiveCamera() = new(1.0, Transformation(), 1.0 )  
end


# function fire_ray(camera, u, v)
#     Ray_StandardFrame = Ray( Point(-camera.distance, 0.0, 0.0), Vec(camera.distance, (1.0-2*u)*camera.aspect_ratio, 2*v-1), 1.0 )
#     return camera.transformation * Ray_StandardFrame
# end
