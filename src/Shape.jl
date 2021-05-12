
abstract type Shape
end

function ray_intersection(shape::Shape, ray::Ray)
    return nothing   #sarebbe meglio far uscire un error
end

struct Sphere
    transformation::Transformation
    Sphere() = new(Transformation())
    Sphere(transformation::Transformation) = new(transformation)
end

struct HitRecord
    world_point::Point
    normal::Normal
    surface_point::Vec2D
    t::Float64
    ray::Ray
end

Base.:≈(H1::HitRecord,H2::HitRecord) = H1.world_point≈H2.world_point && H1.normal≈H2.normal && H1.surface_point≈H2.surface_point && H1.t≈H2.t && H1.ray≈H2.ray
Base.:≈(::Nothing,H2::HitRecord) = false


function _sphere_point_to_uv(point::Point)
    u = atan(point.y, point.x) / (2.0 * pi)
    if u >= 0.0 
        u = u
    else
        u = u + 1.0
    end
    v=acos(point.z) / pi
    return Vec2D( u , v )
end

function _sphere_normal(point::Point, ray_dir::Vec)
    result = Normal(point.x, point.y, point.z)
    if toVec(point)*ray_dir < 0.0
        return result
    else
        return Normal(-1.0*result.x,-1.0*result.y,-1.0*result.z)
    end
end

function ray_intersection(sphere::Sphere, ray::Ray)
    inverse_ray= inverse(sphere.transformation) * ray
    origin_vec = toVec(inverse_ray.origin)
    a = squared_norm(inverse_ray.dir)
    b = 2.0 * origin_vec * inverse_ray.dir
    c = squared_norm(origin_vec) - 1.0
    Δ = b * b - 4 * a * c

    if Δ<0
        println("AAAAAAA")
        return nothing
    else 
        t_1 = ( -b - sqrt(Δ) ) / (2.0 * a)
        t_2 = ( -b + sqrt(Δ) ) / (2.0 * a)
        if t_1 > inverse_ray.tmin && t_1 < inverse_ray.tmax
            first_hit_t = t_1
        elseif t_2 > inverse_ray.tmin && t_2 < inverse_ray.tmax
            first_hit_t = t_2
        else
            return nothing
        end
        
        hit_point = at(inverse_ray, first_hit_t)
    end

    return HitRecord(sphere.transformation * hit_point, sphere.transformation * _sphere_normal(hit_point, inverse_ray.dir), _sphere_point_to_uv(hit_point), first_hit_t, ray )
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

        if intersection != nothing
            continue

        elseif closest != nothing  || (intersection.t < closest.t)
            closest = intersection
        end
    end
    return closest
    
end



#########