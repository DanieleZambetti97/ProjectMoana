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

AAB default orthogonal projection.
           z
           | z=1
           |__________ 
          /|         /|
         / |        / |
        /__________/  |
        |  |       |  |
        |  |_______|__|_________ y
        | /        | /  y=1
    x=1 |/_________|/ 
        /  
       /    
       x


UV mapping of the net of the default AAB. 
        v   
  1 | _ _ _ _ ________ _ _ _ _ _ _ _ _ _ 
    |        |        |                 '
    |        |   y=0  |                 '
2/3 |________|________|________ ________'
    |        |        |        |        |
    |   x=0  |   z=1  |   x=1  |   z=0  |
1/3 |________|________|________|________|
    |        |        |                 '
    |        |   y=1  |                 '
    |________|________|_________________'___ u
    0       1/4      2/4      3/4       1

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


struct CSGError <: Exception
    msg::String
end

struct ShapeUnion <: Shape
    shape1::Shape
    shape2::Shape
    transformation::Transformation

    ShapeUnion(shape1::Shape,
               shape2::Shape,
               transformation::Transformation=Transformation()) =
               new(shape1, shape2, transformation)
 end
Base.:≈(S1::ShapeUnion,S2::ShapeUnion) = S1.shape1 ≈ S2.shape1 && S1.shape2 ≈ S2.shape2 && S1.transformation ≈ S2.transformation

struct ShapeDifference <: Shape
    shape1::Shape
    shape2::Shape
    transformation::Transformation

    function ShapeDifference(shape1::Shape, shape2::Shape, transformation::Transformation=Transformation())
        if isa(shape1, Plane) || isa(shape2, Plane)
            throw(CSGError("It's not possibile to use Plane shapes in ShapeDifference, try whit AAB and Spheres"))
        end
        return new(shape1, shape2, transformation)
    end
 end
Base.:≈(S1::ShapeDifference,S2::ShapeDifference) = S1.shape1 ≈ S2.shape1 && S1.shape2 ≈ S2.shape2 && S1.transformation ≈ S2.transformation
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
    t::Array{Float32}
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
function ray_intersection(shape::Shape, ray::Ray)
    return nothing   #sarebbe meglio far uscire un error
end

## Overloading for ray_intersection with the struct World
function ray_intersection(world::World, ray::Ray)
    closest = nothing
    for i ∈ 1:length(world.shapes)
        intersection = ray_intersection(world.shapes[i], ray)

        if intersection === nothing
            continue
        elseif closest === nothing  || (intersection.t[1] < closest.t[1])
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
        if inverse_ray.tmin < t_1 < inverse_ray.tmax
            first_hit_t = t_1
        elseif inverse_ray.tmin < t_2 < inverse_ray.tmax
            first_hit_t = t_2
        else
            return nothing
        end
        
        hit_point = at(inverse_ray, first_hit_t)
    end

    return HitRecord(sphere.transformation * hit_point,
                     sphere.transformation * _sphere_normal(hit_point, inverse_ray.dir),
                     _sphere_point_to_uv(hit_point),
                     sort([t_1, t_2]),
                     ray,
                     sphere)
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
    return HitRecord(plane.transformation * hit_point,
                     plane.transformation * _plane_normal(hit_point, inverse_ray.dir),
                     _plane_point_to_uv(hit_point),
                     [t],
                     ray,
                     plane)
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
        
    if inverse_ray.tmin ≤ t_min ≤ inverse_ray.tmax
        hit_point = at(inverse_ray, t_min)
        return HitRecord(cube.transformation * hit_point,
                         cube.transformation * _cube_normal(hit_point, inverse_ray.dir),
                         _cube_point_to_uv(hit_point),
                         [t_min, t_max],
                         ray,
                         cube)
    elseif inverse_ray.tmin ≤ t_max ≤ inverse_ray.tmax
        hit_point = at(inverse_ray, t_max)
        return HitRecord(cube.transformation * hit_point,
                         cube.transformation * _cube_normal(hit_point, inverse_ray.dir),
                         _cube_point_to_uv(hit_point),
                         [t_max, t_min],
                         ray,
                         cube)
    else
        return nothing 
    end
end

function ray_intersection(union::ShapeUnion, ray::Ray)
    inverse_ray= inverse(union.transformation) * ray

    intersection1 = ray_intersection(union.shape1, inverse_ray)
    intersection2 = ray_intersection(union.shape2, inverse_ray)
    if (intersection1, intersection2) == (nothing, nothing) 
        return nothing
    elseif intersection1 === nothing
        return HitRecord(intersection2.world_point,
                         intersection2.normal,
                         intersection2.surface_point,
                         intersection2.t,
                         ray,
                         union.shape2)
    elseif intersection2 === nothing
        return HitRecord(intersection1.world_point,
                         intersection1.normal,
                         intersection1.surface_point,
                         intersection1.t,
                         ray,
                         union.shape1)
    elseif intersection1.t < intersection2.t
        return HitRecord(intersection1.world_point,
                         intersection1.normal,
                         intersection1.surface_point,
                         intersection1.t,
                         ray,
                         union.shape1)
    elseif intersection2.t < intersection1.t 
        return HitRecord(intersection2.world_point,
                         intersection2.normal,
                         intersection2.surface_point,
                         intersection2.t,
                         ray,
                         union.shape2)
    end
end

function ray_intersection(difference::ShapeDifference, ray::Ray)
    inverse_ray= inverse(difference.transformation) * ray

    intersection1 = ray_intersection(difference.shape1, inverse_ray)
    if intersection1 === nothing
        return nothing
    end

    intersection2 = ray_intersection(difference.shape2, inverse_ray)
    if intersection2 === nothing
        return HitRecord(intersection1.world_point,
        intersection1.normal,
        intersection1.surface_point,
        [intersection1.t[1]],
        ray,
        difference.shape1)

    end

    ### Check if there is intersection between the two shapes along the ray direction, otherwise return nothing
    if intersection1.t[1]<intersection2.t[2] 
        t_shape_near = intersection1.t
        t_shape_far = intersection2.t
    else
        t_shape_near = intersection1.t
        t_shape_far = intersection2.t
    end
    if t_shape_near[2] < t_shape_far[1]
        return nothing
    end

    t_accettable = [intersection1.t[1],intersection1.t[2],intersection2.t[1],intersection2.t[2]]
    # if intersection2.t[1] < intersection1.t[1] < intersection2.t[2]
    #     splice!(t_accettable, findall(x->x==intersection1.t[1], t_accettable)[1])
    # elseif intersection2.t[1] < intersection1.t[2] < intersection2.t[2]
    #     splice!(t_accettable, findall(x->x==intersection1.t[2], t_accettable)[1])
    # elseif intersection1.t[1] < intersection2.t[1] < intersection1.t[2]
    #     splice!(t_accettable, findall(x->x==intersection2.t[1], t_accettable)[1])
    # elseif intersection1.t[1] < intersection2.t[2] < intersection1.t[2]
    #     splice!(t_accettable, findall(x->x==intersection2.t[2], t_accettable)[1])
    # end

    # if length(t_accettable) == 0
    #     return nothing
    # elseif length(t_accettable) == 1
    #     return

    if intersection1.t[1] < intersection2.t[1]
        return HitRecord(intersection1.world_point,
                         intersection1.normal,
                         intersection1.surface_point,
                         [intersection1.t[1]],
                         ray,
                         difference.shape1)
    elseif intersection2.t[1]<intersection1.t[1]<intersection1.t[2]<intersection2.t[2]
        return nothing
    else
        new_ray = Ray(inverse_ray.origin, inverse_ray.dir, intersection2.t[1]+1.10e-10, Inf, inverse_ray.depth)
        new_intersection = ray_intersection(difference.shape2, new_ray)
        if new_intersection === nothing
            println(intersection1)
            println(intersection2)
            println(inverse_ray)
            println(new_ray)
            println(t_accettable)
        end
        return HitRecord(new_intersection.world_point,
                         new_intersection.normal,
                         new_intersection.surface_point,
                         [new_intersection.t[1]],
                         ray,
                         difference.shape2)
    end
end
