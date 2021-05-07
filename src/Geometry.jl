# Implementation of new type Vec
struct Vec
    vx::Float64
    vy::Float64
    vz::Float64
end

# Implementation of new type Point
struct Point
    x::Float64
    y::Float64
    z::Float64
end

# Implementation of new type Normal
struct Normal
    x::Float64
    y::Float64
    z::Float64
end

struct Vec2D
    u::Float64
    v::Float64
end
# Implementation of new type Transformation
"""
This struct creates a **Transformation**.

## Arguments
- *m* -> matrix of type Array{Array{Float64}};
- *invm* -> inverse matrix.

If not specified, both of the matrixes are the Identity matrix (4x4).
"""
mutable struct Transformation
    m::Array{Array{Float64}}
    invm::Array{Array{Float64}}
    Transformation(m, invm) = new(m, invm)
    Transformation() = new(ID4x4, ID4x4)
    
end

# Supporting methods for Transformation
function _matr_prod(a, b)
    result = [[0.0 for i in 1:4] for j in 1:4]
    for i in 1:4
        for j in 1:4
            for k in 1:4
                result[i][j] += a[i][k] * b[k][j]
            end
        end
    end
    return result
end

function is_consistent(T::Transformation)
    prod = _matr_prod(T.m, T.invm)
    return isapprox(prod, ID4x4)
end


ID4x4 = [[1.0, 0.0, 0.0, 0.0],
         [0.0, 1.0, 0.0, 0.0],
         [0.0, 0.0, 1.0, 0.0],
         [0.0, 0.0, 0.0, 1.0]]


## BASIC OPERATIONS between Vecs, Normals, Points and Scalars ###############################################################

Base.:isapprox(V1::Vec, V2::Vec) = Base.isapprox(V1.vx,V2.vx, atol = 10^-15) && Base.isapprox(V1.vy,V2.vy, atol = 10^-15) && Base.isapprox(V1.vz,V2.vz, atol = 10^-15)

Base.:isapprox(n1::Normal, n2::Normal) = Base.isapprox(n1.x,n2.x) && Base.isapprox(n1.y,n2.y) && Base.isapprox(n1.z,n2.z)

Base.:+(V1::Vec , V2::Vec )  = Vec((V1.vx+V2.vx), (V1.vy+V2.vy), (V1.vz+V2.vz))

Base.:-(V1::Vec , V2::Vec )   = Vec((V1.vx-V2.vx), (V1.vy-V2.vy), (V1.vz-V2.vz))

Base.:*(V1::Vec , scalar::Real)   = Vec(V1.vx*scalar, V1.vy*scalar, V1.vz*scalar)

Base.:*(scalar::Real, V1::Vec )   = Vec(V1.vx*scalar, V1.vy*scalar, V1.vz*scalar)

Base.:*(V1::Vec , V2::Vec )   = (V1.vx*V2.vx)+(V1.vy*V2.vy)+(V1.vz*V2.vz)

# Cross product Vecs
cross(V1::Vec, V2::Vec) = Vec( (V1.vy * V2.vz - V1.vz * V2.vy), (V1.vz * V2.vx - V1.vx * V2.vz), (V1.vx * V2.vy - V1.vy * V2.vx) )

# Norm
squared_norm(V1::Vec) = V1*V1

norm(V1::Vec) = sqrt(squared_norm(V1))

normalize(V1::Vec) = Vec( (V1.vx/norm(V1)), (V1.vy/norm(V1)), (V1.vz/norm(V1)) )

# Aprroximation for two Point
Base.:isapprox(P1::Point, P2::Point) = Base.isapprox(P1.x,P2.x) && Base.isapprox(P1.y,P2.y) && Base.isapprox(P1.z,P2.z) 

# Sum Point + Vector returning a Point
Base.:+(P::Point, V::Vec) = Point(P.x + V.vx, P.y + V.vy, P.z + V.vz)

# Sum Point + Point returning a Point
Base.:+(P1::Point, P2::Point) = Point(P1.x + P2.x, P1.y + P2.y, P1.z + P2.z)

# Difference Point - Point returning a Vector
Base.:-(P1::Point, P2::Point) = Vec(P1.x - P2.x, P1.y - P2.y, P1.z - P2.z)

# Difference Point - Vector returning a Point
Base.:-(P::Point, V::Vec) = Point(P.x - V.vx, P.y - V.vy, P.z - V.vz)

# Product Point * scalar
Base.:*(P::Point, a) = Point(P.x*a, P.y*a, P.z*a)



## TRANSFORMATON METHODS #######################################################################################################à
function _are_matr_close(m1, m2)
    a = true
    for i in 1:4
        for j in 1:4
            b = isapprox(m1[i][j], m2[i][j])
            a = a*b
        end
    end
    return a
end


function Base.isapprox(M1::Transformation, M2::Transformation)
    return _are_matr_close(M1.m, M2.m) && _are_matr_close(M1.invm, M2.invm)
end

Base.:*(M1::Transformation, M2::Transformation) = Transformation(_matr_prod(M1.m, M2.m), _matr_prod(M2.invm, M1.invm))

Base.:*(M::Transformation, P::Point) = Point( P.x * M.m[1][1] + P.y * M.m[1][2] + P.z * M.m[1][3] + M.m[1][4], 
                                              P.x * M.m[2][1] + P.y * M.m[2][2] + P.z * M.m[2][3] + M.m[2][4], 
                                              P.x * M.m[3][1] + P.y * M.m[3][2] + P.z * M.m[3][3] + M.m[3][4] )

Base.:*(M::Transformation, V::Vec) = Vec( V.vx * M.m[1][1] + V.vy * M.m[1][2] + V.vz * M.m[1][3], 
                                          V.vx * M.m[2][1] + V.vy * M.m[2][2] + V.vz * M.m[2][3], 
                                          V.vx * M.m[3][1] + V.vy * M.m[3][2] + V.vz * M.m[3][3] )

Base.:*(M::Transformation, N::Normal) = Normal( N.x * M.invm[1][1] + N.y * M.invm[2][1] + N.z * M.invm[3][1], 
                                                N.x * M.invm[1][2] + N.y * M.invm[2][2] + N.z * M.invm[3][2], 
                                                N.x * M.invm[1][3] + N.y * M.invm[2][3] + N.z * M.invm[3][3] )


function inverse(M::Transformation)
    return Transformation(M.invm, M.m)
end

# Defining translation, scaling and rotation
function translation(vec)
    m = [[1.0, 0.0, 0.0, vec.vx],
         [0.0, 1.0, 0.0, vec.vy],
         [0.0, 0.0, 1.0, vec.vz],
         [0.0, 0.0, 0.0, 1.0]]
    invm = [[1.0, 0.0, 0.0, -vec.vx],
            [0.0, 1.0, 0.0, -vec.vy],
            [0.0, 0.0, 1.0, -vec.vz],
            [0.0, 0.0, 0.0, 1.0]]
    
    return Transformation(m, invm)
end

   
function scaling(vec)
    m = [[vec.vx, 0.0, 0.0, 0.0],
         [0.0, vec.vy, 0.0, 0.0],
         [0.0, 0.0, vec.vz, 0.0],
         [0.0, 0.0, 0.0, 1.0]]
    invm = [[1 / vec.vx, 0.0, 0.0, 0.0],
            [0.0, 1 / vec.vy, 0.0, 0.0],
            [0.0, 0.0, 1 / vec.vz, 0.0],
            [0.0, 0.0, 0.0, 1.0]]
    
    return Transformation(m, invm)
end
     
# Rotations
"""
It defines a rotation around the x axis of an angle α (in RADIANTS!!).
"""  
function rotation_x(angle_rad::Float64)
    sinang, cosang = sin(angle_rad), cos(angle_rad)
    m = [[1.0, 0.0, 0.0, 0.0],
         [0.0, cosang, -sinang, 0.0],
         [0.0, sinang, cosang, 0.0],
         [0.0, 0.0, 0.0, 1.0]]
    invm = [[1.0, 0.0, 0.0, 0.0],
            [0.0, cosang, sinang, 0.0],
            [0.0, -sinang, cosang, 0.0],
            [0.0, 0.0, 0.0, 1.0]]
    
    return Transformation(m, invm)
end

"""
It defines a rotation around the y axis of an angle α (in RADIANTS!!).
"""  
function rotation_y(angle_rad::Float64)
    sinang, cosang = sin(angle_rad), cos(angle_rad)
    m = [[cosang, 0.0, sinang, 0.0],
        [0.0, 1.0, 0.0, 0.0],
        [-sinang, 0.0, cosang, 0.0],
        [0.0, 0.0, 0.0, 1.0]]
    invm = [[cosang, 0.0, -sinang, 0.0],
            [0.0, 1.0, 0.0, 0.0],
            [sinang, 0.0, cosang, 0.0],
            [0.0, 0.0, 0.0, 1.0]]   
        
    return Transformation(m, invm)
end
  
"""
It defines a rotation around the z axis of an angle α (in RADIANTS!!).
"""      
function rotation_z(angle_rad::Float64)
    sinang, cosang = sin(angle_rad), cos(angle_rad)
    m = [[cosang, -sinang, 0.0, 0.0],
         [sinang, cosang, 0.0, 0.0],
         [0.0, 0.0, 1.0, 0.0],
         [0.0, 0.0, 0.0, 1.0]]
    invm = [[cosang, sinang, 0.0, 0.0],
            [-sinang, cosang, 0.0, 0.0],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]]
    
    return Transformation(m, invm)
end

