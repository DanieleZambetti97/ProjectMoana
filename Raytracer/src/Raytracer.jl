module Raytracer

greet() = print("Hello World!")
import ColorTypes

import Base.:*, Base.:+ 

# Definition of product "scalar * color"
Base.:*(c::ColorTypes.RGB{T}, scalar) where {T} = ColorTypes.RGB(c.r*scalar, c.g*scalar, c.b*scalar)









#Definition of sum "color + color"
Base.:+(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = c1 + c2

end # module
