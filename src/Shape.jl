
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

#########

