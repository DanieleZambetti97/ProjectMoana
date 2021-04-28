import ProjectMoana: Point, Vec
import Base.:≈

export Ray, at

"""
Denni <3 ...
"""
struct Ray
    origin::Point 
    dir::Vec      
    tmin::Float64
    tmax::Float64 
    depth::Int16
    
    Ray(origin, dir) = new(origin, dir, 1e-5, Inf, 0) 
end

# at method
at(ray::Ray, t::Float64) = ray.origin + ray.dir*t

# approx method for testing Ray
Base.:isapprox(ray1::Ray, ray2::Ray) = Base.isapprox(ray1.origin, ray2.origin) && Base.isapprox(ray1.dir, ray2.dir)

