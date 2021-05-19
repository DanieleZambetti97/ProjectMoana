## Code for SHAPES #########################################################################################

abstract type Shape
end
Base.:≈(S1::Shape,S2::Shape) = S1.transformation ≈ S2.transformation && S1.material ≈ S2.material

"""
    Sphere(T)

It creates a **Sphere**, where T is a generic ``Transformation`` applied to the unit sphere centered in the origin, M is the ``Material`` of the sphere.
"""
struct Sphere <: Shape
    transformation::Transformation
    material::Material
    Sphere() = new(Transformation(), Material())
    Sphere(transformation::Transformation) = new(transformation, Material())
    Sphere(material::Material) = new(Transformation(), material)
end

## Hidden methods for sphere
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

"""
    Plane(T,M)

It creates a **Plane**, where T is a generic ``Transformation`` applied to the XY palane, M is the ``Material`` of the plane.
"""
struct Plane <: Shape
    transformation::Transformation
    material::Material
    Plane() = new(Transformation(), Material())
    Plane(transformation::Transformation) = new(transformation, Material())
    Plane(material::Material) = new(Transformation(), material)
end

## Hidden methods for plane
function _plane_point_to_uv(point::Point)
    u = point.x - floor(point.x)
    v = point.y - floor(point.y)
    return Vec2D(u,v)
end

function _plane_normal(point::Point, origin::Vec, ray_dir::Vec)
    result = Vec(point.x-origin.vx, point.y-origin.vy, point.z-origin.vz)
    result = normalize(result)
    if ray_dir.vz > 0.0
        return Normal(result.vx,result.vy,result.vz)
    else
        return Normal(-1.0*result.vx,-1.0*result.vy,-1.0*result.vz)
    end
end

## Code for HITRECORD ###########################################################################################################################

"""
    HitRecord()

## Arguments:
- world point;
- normal;
- surface point (u & v coordinates);
- t (distance covered by the ray);
- ray;
- shape
"""
struct HitRecord
    world_point::Point
    normal::Normal
    surface_point::Vec2D
    t::Float64
    ray::Ray
    shape::Shape
end

Base.:≈(H1::HitRecord,H2::HitRecord) = H1.world_point≈H2.world_point && H1.normal≈H2.normal && H1.surface_point≈H2.surface_point && H1.t≈H2.t && H1.ray≈H2.ray && H1.shape ≈ H2.shape
Base.:≈(::Nothing,H2::HitRecord) = false

## Definition of WORLD ############################################################################################################################################

"""
    World()
It creates a **World** with an array of shapes.
"""
struct World
    shapes::Array{Shape}
    World() = new([]) 
end

# Adding shapes method
function add_shape(world::World, shape::Shape)
    push!(world.shapes, shape)
end

## RAY INTERSECTION ###############################################################################################################################

"""
    ray_intersection(shape, ray)

Evaluates the intersection between a shape (or a World) and a ray, returning a HitRecord.
"""
function ray_intersection(shape::Shape, ray::Ray)
    return nothing   #sarebbe meglio far uscire un error
end

## Overloading for ray_intersection with the struct World
function ray_intersection(world::World, ray::Ray)
    closest = nothing
    for i ∈ 1:length(world.shapes)
        intersection = ray_intersection(world.shapes[i], ray)

        if intersection == nothing
            continue
        elseif closest == nothing  || (intersection.t < closest.t)
            closest = intersection
        end
    
    end
    return closest
    
end

function ray_intersection(sphere::Sphere, ray::Ray)
    inverse_ray= inverse(sphere.transformation) * ray
    origin_vec = toVec(inverse_ray.origin)
    a = squared_norm(inverse_ray.dir)
    b = 2.0 * origin_vec * inverse_ray.dir
    c = squared_norm(origin_vec) - 1.0
    Δ = b * b - 4 * a * c

    if Δ<0
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

    return HitRecord(sphere.transformation * hit_point, sphere.transformation * _sphere_normal(hit_point, inverse_ray.dir), _sphere_point_to_uv(hit_point), first_hit_t, ray, sphere )
end

function ray_intersection(plane::Plane, ray::Ray)
    inverse_ray= inverse(plane.transformation) * ray
    origin_vec = toVec(inverse_ray.origin)

    if inverse_ray.dir.vz == 0
        return nothing
    else 
        t = - inverse_ray.origin.z / inverse_ray.dir.vz
        if t<0
            return nothing
        else
            hit_point = at(inverse_ray, t)
        end
    end
    return HitRecord(plane.transformation * hit_point, plane.transformation * _plane_normal(hit_point, origin_vec, inverse_ray.dir), _plane_point_to_uv(hit_point), t, ray, plane )
end