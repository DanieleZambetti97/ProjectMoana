export Vec, Point, cross, squared_norm, norm, normalize

# Implementation of new type Vec
struct Vec
    x::Float64
    y::Float64
    z::Float64

end

# Implementation of new type Point
struct Point
    x::Float64
    y::Float64
    z::Float64
end

# Basic operations for Vec
Base.:isapprox(V1::Vec, V2::Vec) = Base.isapprox(V1.x, V2.x) && Base.isapprox(V1.y, V2.y) && Base.isapprox(V1.z, V2.z)

Base.:+(V1::Vec , V2::Vec ) = Vec( (V1.x+V2.x), (V1.y+V2.y), (V1.z+V2.z) )

Base.:-(V1::Vec , V2::Vec ) = Vec( (V1.x-V2.x), (V1.y-V2.y), (V1.z-V2.z) )

Base.:*(V1::Vec , scalar::Real) = Vec(V1.x*scalar, V1.y*scalar, V1.z*scalar)

Base.:*(scalar::Real, V1::Vec ) = Vec(V1.x*scalar, V1.y*scalar, V1.z*scalar)

# Dot and cross product
Base.:*(V1::Vec , V2::Vec ) = (V1.x*V2.x)+(V1.y*V2.y)+(V1.z*V2.z)

cross(V1::Vec, V2::Vec) = Vec( (V1.y * V2.z - V1.z * V2.y), (V1.z * V2.x - V1.x * V2.z), (V1.x * V2.y - V1.y * V2.x) )

# Norm and versor
squared_norm(V1::Vec) = V1*V1

norm(V1::Vec) = sqrt(squared_norm(V1))

normalize(V1::Vec) = Vec( (V1.x/norm(V1)), (V1.y/norm(V1)), (V1.z/norm(V1)) )



# Basic operations for Point
Base.:isapprox(P1::Point, P2::Point) = Base.isapprox(P1.x,P2.x) && Base.isapprox(P1.y,P2.y) && Base.isapprox(P1.z,P2.z) 

Base.:+(P1::Point, P2::Point) = Point(P1.x + P2.x, P1.y + P2.y, P1.z + P2.z)

Base.:*(P::Point, a) = Point(P.x*a, P.y*a, P.z*a)

# Sum Point + Vector returning a Point
Base.:+(P::Point, V::Vec) = Point(P.x + V.x, P.y + V.y, P.z + V.z)

# Difference Point - Point returning a Vector
Base.:-(P1::Point, P2::Point) = Vec(P1.x - P2.x, P1.y - P2.y, P1.z - P2.z)

# Difference Point - Vector returning a Point
Base.:-(P::Point, V::Vec) = Point(P.x - V.x, P.y - V.y, P.z - V.z)
