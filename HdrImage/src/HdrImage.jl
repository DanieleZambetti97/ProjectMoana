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

# Check if the coordinates pass are valid
valid_coordinates(HdrImage(), x, y)
    return ((x >= 0) && (x < HdrImage.width) && (y >= 0) && (y < HdrImage.height)) 

# Save an HdrImage on a file in PFM format
write_pfm()

end # module
