module RaytracerColors

import ColorTypes
import Base.:+, Base.:*, Base.:≈
import Crayons
import Colors


greet(name) = println("Hello $(name)! Moana welcomes you!")
greet() = println("Hello World! Moana welcomes you!")

# Sum of two colors 
Base.:+(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB((c1.r + c2.r), (c1.g + c2.g), (c1.b + c2.b))

# Difference of two colors 
Base.:-(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB((c1.r - c2.r), (c1.g - c2.g), (c1.b - c2.b))

# Product "scalar * color"
Base.:*(c::ColorTypes.RGB{T}, scalar) where {T} = ColorTypes.RGB(c.r*scalar, c.g*scalar, c.b*scalar)

# Product "color * scalar"
Base.:*(scalar, c::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB(c.r*scalar, c.g*scalar, c.b*scalar)

# Aprroxmation for two color
Base.:isapprox(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = Base.isapprox(c1.r,c2.r) && Base.isapprox(c1.g,c2.g) && Base.isapprox(c1.b,c2.b) 

# Printing a color on the terminal
printcol(color) = println(Crayons.Crayon(foreground = color, bold = true), "Nice color!")


end # module
