
using ColorTypes

import Base.:+, Base.:*, Base.:≈
import Crayons.Crayon

export printcol, luminosity

## Redifing the BASIC OPERATIONS between colors #########################################################################################

# Sum of two colors 
Base.:+(c1::RGB{T}, c2::RGB{T}) where {T} = RGB((c1.r + c2.r), (c1.g + c2.g), (c1.b + c2.b))

# Difference of two colors 
Base.:-(c1::RGB{T}, c2::RGB{T}) where {T} = RGB((c1.r - c2.r), (c1.g - c2.g), (c1.b - c2.b))

# Product "scalar * color"
Base.:*(c::RGB{T}, scalar::Real) where {T} = RGB(c.r*scalar, c.g*scalar, c.b*scalar)

# Product "color * scalar"
Base.:*(scalar::Real, c::RGB{T}) where {T} = RGB(c.r*scalar, c.g*scalar, c.b*scalar)

# Aprroxmation for two color
Base.:isapprox(c1::RGB{T}, c2::RGB{T}) where {T} = Base.isapprox(c1.r,c2.r) && Base.isapprox(c1.g,c2.g) && Base.isapprox(c1.b,c2.b) 

# Printing a color on the terminal
printcol(color) = println( Crayon(foreground = color, bold = true), "
____*##########*
__*##############
__################
_##################_________*####*
__##################_____*##########
__##################___*#############
___#################*_###############*
____#################################*
______###############################
_______#############################
________=##########################
__________########################
___________*#####################
____________*##################
_____________*###############
_______________#############
________________##########
________________=#######*
_________________######
__________________####
__________________###
___________________#")


# Calculating the luminosity of a pixel

luminosity(pixel::RGB) = (max(pixel.r, pixel.g, pixel.b) + min(pixel.r, pixel.g, pixel.b))/2


