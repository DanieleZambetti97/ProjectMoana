module Raytracer

import ColorTypes
import Base.:+, Base.:*, Base.:≈

greet(name) = print("Hello $(name)! Moana welcomes you!")

# Definition of the sum of two colors 

Base.:+(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB((c1.r + c2.r), (c1.g + c2.g), (c1.b + c2.b))


# Definition of the difference of two colors 

Base.:-(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB((c1.r - c2.r), (c1.g - c2.g), (c1.b - c2.b))


# Definition of the product "scalar * color"

Base.:*(c::ColorTypes.RGB{T}, scalar) where {T} = ColorTypes.RGB(c.r*scalar, c.g*scalar, c.b*scalar)


# Definition of product "color * scalar"

Base.:*(scalar, c::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB(c.r*scalar, c.g*scalar, c.b*scalar)

end # module
