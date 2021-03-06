## Code for RAYS #########################################################################################################################

"""
Ray( origin, dir, tmin, tmax, depth)

It creates a **Ray**. When not specified tmin = 1e-5, tmax = +∞ and depth = 0.f0
"""
struct Ray
    origin::Point 
    dir::Vec
    tmin::Float32
    tmax::Float32 
    depth::Int16
    
    Ray( origin, dir, tmin=1e-5, tmax=Inf, depth=0) = new(origin, dir, tmin, tmax, depth)

end

Base.:*(T::Transformation, R::Ray) = Ray(T*R.origin, T*R.dir, R.tmin, R.tmax, R.depth )

Base.:isapprox(ray1::Ray, ray2::Ray) = isapprox(ray1.origin, ray2.origin) && isapprox(ray1.dir, ray2.dir)

"""
    at(ray, t)

It calculates the position of the ray at the instant *t*.
"""
at(ray::Ray, t::Number) = ray.origin + ray.dir*t



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

    Sphere(transformation::Transformation = Transformation(),
           material::Material = Material()) =
           new(transformation, material)
#    Sphere() = new(Tansformation(), Material())
end

## Hidden methods for sphere
function _sphere_point_to_uv(point::Point)
    u = Float32(atan(point.y, point.x) / (2.0f0 * pi))
    if u >= 0.f0 
        u = u
    else
        u = u + 1.f0
    end
    if abs(point.z)>1.f0
        v=1.f0
    else
        v=Float32(acos(point.z) / pi)
    end
    return Vec2D( u , v )
end

function _sphere_normal(point::Point, ray_dir::Vec)
    result = Normal(point.x, point.y, point.z)
    if toVec(point)*ray_dir < 0.f0
        return result
    else
        return Normal(-1.f0*result.x,-1.f0*result.y,-1.f0*result.z)
    end
end

"""
    Plane(T,M)

It creates a **Plane**, where T is a generic ``Transformation`` applied to the XY palane, M is the ``Material`` of the plane.
"""
struct Plane <: Shape
    transformation::Transformation
    material::Material

    Plane(transformation::Transformation=Transformation(),
          material::Material=Material()) =
          new(transformation, material)
end

## Hidden methods for plane
function _plane_point_to_uv(point::Point)
    u = Float32(point.x - floor(point.x))
    v = Float32(point.y - floor(point.y))
    return Vec2D(u,v)
end

function _plane_normal(point::Point, ray_dir::Vec)
    result = Normal(0.f0, 0.f0, 1.f0)
    Vec(0.f0, 0.f0, 1.f0) * ray_dir < 0.f0 ? nothing : result = Normal(0.f0, 0.f0, -1.f0)
    return result
end

"""
    AAB(T,M)

It creates a **axis-aligned box**, where T is a generic ``Transformation`` and  M is the ``Material`` of the cube. 
By default the AAB is generated with the rear-bottom left vertex in (0,0,0), while the front-top right vertex is in (1,1,1).
"""
struct AAB <: Shape
    transformation::Transformation
    material::Material

    AAB(transformation::Transformation=Transformation(),
        material::Material=Material()) =
        new(transformation, material)
end

## Hidden methods for AAB
function _cube_point_to_uv(point::Point)
    if point.x == 0
        u = point.z
        v = 2.f0 - point.y 
    elseif point.x == 1
        u = 3.f0 - point.z 
        v = 2.f0 - point.y
    elseif point.z == 0
        u = 4.f0 - point.x 
        v = 2.f0 - point.y
    elseif point.z == 1
        u = 1.f0 + point.x
        v = 2.f0 - point.y 
    elseif point.y == 0
        u = 1.f0 + point.x
        v = 3.f0 - point.z
    elseif point.y == 1
        u = 1.f0 + point.x 
        v = point.z
    else 
        u = 12.f0
        v = 12.f0
    end
    return Vec2D(u/4.f0, v/3.f0)
end

function _cube_normal(point::Point, ray_dir::Vec)
    if point.x == 0 || point.x == 1
        result = Vec(1.f0, 0.f0, 0.f0)
    elseif point.y == 0 || point.y == 1
        result = Vec(0.f0, 1.f0, 0.f0)
    elseif point.z == 0 || point.z == 1
        result = Vec(0.f0, 0.f0, 1.f0)
    else 
        result = Vec(9,9,9)############!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
    result * ray_dir < 0.f0 ? nothing : result = result * -1.f0
    return Normal(result.x, result.y, result.z)
end

"""
    LightPoint(P,M)

It creates a **point light source** in the ``Position`` P. M is the ``Material`` of the object, the only important fild is the ``emettide_radiance``.
By default the source is placed in (0.,0.,0.) and has an ``emettide_radiance`` RGB(1.,1,.1.).
"""

struct LightPoint <: Shape
    point::Point
    material::Material

    LightPoint(point::Point=Point(0.,0.,0.),
           material::Material = Material()) =
           new(point, material)
end
Base.:≈(S1::LightPoint,S2::LightPoint) = S1.point ≈ S2.point && S1.material ≈ S2.material

## Code for HITRECORD ###########################################################################################################################

"""
    HitRecord(world_point, normal, surface_point, t, ray, shape)

## Arguments:
- world point;
- normal;
- surface point (u & v coordinates);
- t (distance covered by the ray);
- ray;
- shape.
"""
struct HitRecord
    world_point::Point
    normal::Normal
    surface_point::Vec2D
    t::Float32
    ray::Ray
    shape::Shape
end

Base.:≈(H1::HitRecord,H2::HitRecord) = H1.world_point≈H2.world_point && H1.normal≈H2.normal && H1.surface_point≈H2.surface_point && H1.t ≈ H2.t && H1.ray≈H2.ray && H1.shape ≈ H2.shape
#Base.:≈(H1::HitRecord,H2::HitRecord) = H1.world_point≈H2.world_point && H1.normal≈H2.normal && H1.surface_point≈H2.surface_point && isapprox(H1.t,H2.t, atol=5*10^-2) && H1.ray≈H2.ray && H1.shape ≈ H2.shape
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
struct ShapeError <: Exception
    msg::String
end

function ray_intersection(shape::Shape, ray::Ray)
    throw(ShapeError("Ray intersection whit shape $shape are not supported"))
end

## Overloading for ray_intersection with the struct World
function ray_intersection(world::World, ray::Ray)
    closest = nothing
    for i ∈ 1:length(world.shapes)
        intersection = ray_intersection(world.shapes[i], ray)

        if intersection === nothing
            continue
        elseif closest === nothing  || (intersection.t < closest.t)
            closest = intersection
        end
    
    end
    return closest
    
end

function ray_intersection(sphere::Sphere, ray::Ray)
    inverse_ray= inverse(sphere.transformation) * ray
    origin_vec = toVec(inverse_ray.origin)
    a = Float32(squared_norm(inverse_ray.dir))
    b = Float32(2.0 * origin_vec * inverse_ray.dir)
    c = Float32(squared_norm(origin_vec) - 1.f0)
    Δ = Float32(b * b - 4 * a * c)

    if Δ<0
        return nothing
    else 
        t_1 = Float32(( -b - sqrt(Δ) ) / (2.0 * a))
        t_2 = Float32(( -b + sqrt(Δ) ) / (2.0 * a))
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

    if inverse_ray.dir.z ≈ 0
        return nothing
    else 
        t = - inverse_ray.origin.z / inverse_ray.dir.z
        if inverse_ray.tmin < t < inverse_ray.tmax
            hit_point = at(inverse_ray, t)
        else
            return nothing
        end
    end
    return HitRecord(plane.transformation * hit_point, plane.transformation * _plane_normal(hit_point, inverse_ray.dir), _plane_point_to_uv(hit_point), t, ray, plane )
end

function ray_intersection(cube::AAB, ray::Ray)
    inverse_ray= inverse(cube.transformation) * ray
    origin_vec = toVec(inverse_ray.origin)
    t_=zeros(2)

    t_min ,t_max = sort( [- inverse_ray.origin.x / inverse_ray.dir.x , (1. - inverse_ray.origin.x) / inverse_ray.dir.x] )
    t_ymin ,t_ymax = sort( [- inverse_ray.origin.y / inverse_ray.dir.y , (1. - inverse_ray.origin.y) / inverse_ray.dir.y] )

    if (t_min > t_ymax) || (t_ymin > t_max)
        return nothing
    end
    t_min = max(t_min, t_ymin)
    t_max = min(t_max, t_ymax)

    t_zmin ,t_zmax = sort( [- inverse_ray.origin.z / inverse_ray.dir.z , (1. - inverse_ray.origin.z) / inverse_ray.dir.z] )

    if (t_min > t_zmax) || (t_zmin > t_max)
        return nothing
    end
    t_min = max(t_min, t_zmin)
    t_max = min(t_max, t_zmax)
        
    if (inverse_ray.tmin ≤ t_min ≤ inverse_ray.tmax)
        hit_point = at(inverse_ray, t_min)
        return HitRecord(cube.transformation * hit_point, cube.transformation * _cube_normal(hit_point, inverse_ray.dir), _cube_point_to_uv(hit_point), t_min, ray, cube)
    elseif (inverse_ray.tmin ≤ t_max ≤ inverse_ray.tmax)
        hit_point = at(inverse_ray, t_max)
        return HitRecord(cube.transformation * hit_point, cube.transformation * _cube_normal(hit_point, inverse_ray.dir), _cube_point_to_uv(hit_point), t_max, ray, cube)
    else
        return nothing 
    end
end

function ray_intersection(light::LightPoint, ray::Ray)
    return nothing
end
