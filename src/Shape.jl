
abstract type Shape
end

function ray_intersection(shape::Shape, ray::Ray)
    return nothing
end

struct Sphere
    r::Float64
end

struct HitRecord
    world_point::Point
    normal::Normal
    surface_point::Vec2D
    t::Float64
    ray::Ray
end

Base.:≈(H1::HitRecord,H2::HitRecord) = H1.world_point≈H2.world_point && H1.normal≈H2.normal && H1.surface_point≈H2.surface_point && H1.t≈H2.t && H1.ray≈H2.ray

function ray_intersection(sphere::Sphere, ray::Ray)
end

# Defining the sturct World 

struct Wolrd
    shapes::Array{Shape}
    Wolrd() = new([]) 
end

# Adding shapes method
add_shape(world::Wolrd, shape::Shape) = append!(world.shapes, shape)

# Overloading for ray_intersection with the struct Wolrd
function ray_intersection(world::Wolrd, ray::Ray)
    closest = nothing

    for i ∈ 1:length(world.shapes)
        intersection = ray_intersection(world.shapes[i], ray)
        if intersection = nothing
            continue
        elseif intersection.t <  
    end

end



#########

