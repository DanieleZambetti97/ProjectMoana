module HdrImage
import Colors
import ColorTypes
import Base

greet() = print("Hello World!")

mutable struct HdrImages
    heigth::Int
    width::Int
    pixels::Array{ColorTypes.RGB, 1}
    HdrImages(w, h) = new(w, h, [ColorTypes.RGB() for i in 1:h*w])
end

#img = HdrImage(10, 5, pixel)

end # module
