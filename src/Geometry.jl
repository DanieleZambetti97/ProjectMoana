# Implementation of new type Vec
struct Vec
    x::Float32
    y::Float32
    z::Float32
end

# Implementation of new type Point
struct Point
    x::Float32
    y::Float32
    z::Float32
end

# Implementation of new type Normal
struct Normal
    x::Float32
    y::Float32
    z::Float32
end

struct Vec2D
    u::Float32
    v::Float32
end

# Implementation of new type Transformation
"""
    Transformation(m, invm)
    Transformation()

It creates a **Transformation**.

## Arguments
- *m* -> matrix of type Array{Array{Float32}};
- *invm* -> inverse matrix.

If not specified, both of the matrixes are the Identity matrix (4x4).
"""
mutable struct Transformation
    m::Matrix{Float32}
    invm::Matrix{Float32}

    Transformation(m=ID4x4, invm=ID4x4) = new(m, invm)
end

# Supporting methods for Transformation
function is_consistent(T::Transformation)
    prod = T.m * T.invm
    return isapprox(prod, ID4x4)
end


ID4x4 = Matrix{Float32}(I, 4, 4)


## BASIC OPERATIONS between Vecs, Normals, Points and Scalars ###############################################################

Base.:isapprox(V1::Vec, V2::Vec) = Base.isapprox(V1.x,V2.x, atol = 5f-6) && Base.isapprox(V1.y,V2.y, atol = 5f-6) && Base.isapprox(V1.z,V2.z, atol = 5f-6)

Base.:isapprox(n1::Normal, n2::Normal) = Base.isapprox(n1.x,n2.x, atol = 5f-6) && Base.isapprox(n1.y,n2.y, atol = 5f-6) && Base.isapprox(n1.z,n2.z, atol = 5f-6)

Base.:+(V1::Vec , V2::Vec )  = Vec((V1.x+V2.x), (V1.y+V2.y), (V1.z+V2.z))

Base.:-(V1::Vec , V2::Vec )   = Vec((V1.x-V2.x), (V1.y-V2.y), (V1.z-V2.z))

Base.:*(V1::Vec , scalar::Real)   = Vec(V1.x*scalar, V1.y*scalar, V1.z*scalar)

Base.:*(scalar::Real, V1::Normal )   = Normal(V1.x*Float32(scalar), V1.y*Float32(scalar), V1.z*Float32(scalar))

Base.:*(V1::Normal , scalar::Real)   = Normal(V1.x*Float32(scalar), V1.y*Float32(scalar), V1.z*Float32(scalar))

Base.:*(scalar::Real, V1::Vec )   = Vec(V1.x*scalar, V1.y*scalar, V1.z*scalar)
Base.:*(V1::Vec , V2::Vec )   = (V1.x*V2.x)+(V1.y*V2.y)+(V1.z*V2.z)

Base.:≈(V1::Vec2D, V2::Vec2D) = Base.isapprox(V1.u, V2.u, atol = 5f-6)  && isapprox(V1.v, V2.v, atol = 5f-6)

# Cross product Vecs
cross(V1::Vec, V2::Vec) = Vec( (V1.y * V2.z - V1.z * V2.y), (V1.z * V2.x - V1.x * V2.z), (V1.x * V2.y - V1.y * V2.x) )

# Norm
squared_norm(V1::Vec) = V1*V1

norm(V1::Vec) = sqrt(squared_norm(V1))

normalize(V1::Vec) = Vec( (V1.x/norm(V1)), (V1.y/norm(V1)), (V1.z/norm(V1)) )

# Aprroximation for two Point
Base.:isapprox(P1::Point, P2::Point) = Base.isapprox(P1.x,P2.x, atol = 5f-6) && Base.isapprox(P1.y,P2.y, atol = 5f-6) && Base.isapprox(P1.z,P2.z, atol = 5f-6) 

# Sum Point + Vector returning a Point
Base.:+(P::Point, V::Vec) = Point(P.x + V.x, P.y + V.y, P.z + V.z)

# Sum Point + Point returning a Point
Base.:+(P1::Point, P2::Point) = Point(P1.x + P2.x, P1.y + P2.y, P1.z + P2.z)

# Difference Point - Point returning a Vector
Base.:-(P1::Point, P2::Point) = Vec(P1.x - P2.x, P1.y - P2.y, P1.z - P2.z)

# Difference Point - Vector returning a Point
Base.:-(P::Point, V::Vec) = Point(P.x - V.x, P.y - V.y, P.z - V.z)

# Product Point * scalar
Base.:*(P::Point, a) = Point(P.x*a, P.y*a, P.z*a)

# Convert a Point into a Vec
function toVec(point::Union{Point,Normal,Vec})
    return Vec(point.x,point.y,point.z)
end

## TRANSFORMATON METHODS #######################################################################################################à

function Base.isapprox(M1::Transformation, M2::Transformation)
    return M1.m ≈ M2.m && M1.invm ≈ M2.invm
end

Base.:*(M1::Transformation, M2::Transformation) = Transformation(M1.m * M2.m, M2.invm * M1.invm)

Base.:*(M::Transformation, P::Point) = Point( P.x * M.m[1,1] + P.y * M.m[1,2] + P.z * M.m[1,3] + M.m[1,4], 
                                              P.x * M.m[2,1] + P.y * M.m[2,2] + P.z * M.m[2,3] + M.m[2,4], 
                                              P.x * M.m[3,1] + P.y * M.m[3,2] + P.z * M.m[3,3] + M.m[3,4] )

Base.:*(M::Transformation, V::Vec) = Vec( V.x * M.m[1,1] + V.y * M.m[1,2] + V.z * M.m[1,3], 
                                          V.x * M.m[2,1] + V.y * M.m[2,2] + V.z * M.m[2,3], 
                                          V.x * M.m[3,1] + V.y * M.m[3,2] + V.z * M.m[3,3] )

Base.:*(M::Transformation, N::Normal) = Normal( N.x * M.invm[1,1] + N.y * M.invm[2,1] + N.z * M.invm[3,1], 
                                                N.x * M.invm[1,2] + N.y * M.invm[2,2] + N.z * M.invm[3,2], 
                                                N.x * M.invm[1,3] + N.y * M.invm[2,3] + N.z * M.invm[3,3] )


function inverse(M::Transformation)
    return Transformation(M.invm, M.m)
end

# Defining translation, scaling and rotation
function translation(vec)
    m = [1.0f0 0.0f0 0.0f0 vec.x;
         0.0f0 1.0f0 0.0f0 vec.y;
         0.0f0 0.0f0 1.0f0 vec.z;
         0.0f0 0.0f0 0.0f0 1.0f0]
    invm = [1.0f0 0.0f0 0.0f0 -vec.x;
            0.0f0 1.0f0 0.0f0 -vec.y;
            0.0f0 0.0f0 1.0f0 -vec.z;
            0.0f0 0.0f0 0.0f0 1.0f0]
    
    return Transformation(m, invm)
end

   
function scaling(vec)
    m = [vec.x 0.0f0 0.0f0 0.0f0;
         0.0f0 vec.y 0.0f0 0.0f0;
         0.0f0 0.0f0 vec.z 0.0f0;
         0.0f0 0.0f0 0.0f0 1.0f0]
    invm = [1 / vec.x 0.0f0 0.0f0 0.0f0;
            0.0f0 1 / vec.y 0.0f0 0.0f0;
            0.0f0 0.0f0 1 / vec.z 0.0f0;
            0.0f0 0.0f0 0.0f0 1.0f0]
    
    return Transformation(m, invm)
end
     
# Rotations
"""
    rotation_x(angle_rad)

It defines a rotation around the x axis of an angle α (in RADIANTS!!).
"""  
function rotation_x(angle_rad)
    sinang, cosang = Float32(sin(angle_rad)), Float32(cos(angle_rad))
    m = [1.0f0 0.0f0 0.0f0 0.0f0;
         0.0f0 cosang -sinang 0.0f0;
         0.0f0 sinang cosang 0.0f0;
         0.0f0 0.0f0 0.0f0 1.0f0]
    invm = [1.0f0 0.0f0 0.0f0 0.0f0;
            0.0f0 cosang sinang 0.0f0;
            0.0f0 -sinang cosang 0.0f0;
            0.0f0 0.0f0 0.0f0 1.0f0]
    
    return Transformation(m, invm)
end

"""
    rotation_y(angle_rad)

It defines a rotation around the y axis of an angle α (in RADIANTS!!).
"""  
function rotation_y(angle_rad)
    sinang, cosang = Float32(sin(angle_rad)), Float32(cos(angle_rad))
    m = [cosang 0.0f0 sinang 0.0f0;
        0.0f0 1.0f0 0.0f0 0.0f0;
        -sinang 0.0f0 cosang 0.0f0;
        0.0f0 0.0f0 0.0f0 1.0f0]
    invm = [cosang 0.0f0 -sinang 0.0f0;
            0.0f0 1.0f0 0.0f0 0.0f0;
            sinang 0.0f0 cosang 0.0f0;
            0.0f0 0.0f0 0.0f0 1.0f0]   
        
    return Transformation(m, invm)
end
  
"""
    rotation_z(angle_rad)

It defines a rotation around the z axis of an angle α (in RADIANTS!!).
"""      
function rotation_z(angle_rad)
    sinang, cosang = Float32(sin(angle_rad)), Float32(cos(angle_rad))
    m = [cosang -sinang 0.0f0 0.0f0;
         sinang cosang 0.0f0 0.0f0;
         0.0f0 0.0f0 1.0f0 0.0f0;
         0.0f0 0.0f0 0.0f0 1.0f0]
    invm = [cosang sinang 0.0f0 0.0f0;
            -sinang cosang 0.0f0 0.0f0;
            0.0f0 0.0f0 1.0f0 0.0f0;
            0.0f0 0.0f0 0.0f0 1.0f0]
    
    return Transformation(m, invm)
end

###############################################################################
function create_onb(normal_passed::Union{Normal,Vec})
    normal = normalize(toVec(normal_passed))
    sign = copysign(1., normal.z)
    a = (-1. / (sign + normal.z))
    b = (normal.x * normal.y * a)

    e1 = Vec((1. + sign * normal.x * normal.x * a), (sign * b), (-sign * normal.x))
    e2 = Vec((b), (sign + normal.y * normal.y * a), (-normal.y))

    return e1, e2, Vec(normal.x, normal.y, normal.z)
end
