module HdrImages

import Colors
import ColorTypes
import Base

greet() = print("Hello World!")

mutable struct HdrImage
    width::Int
    heigth::Int
    pixels::Array{ColorTypes.RGB, 1}
    HdrImage(w, h) = new(w, h, [ColorTypes.RGB() for i in 1:h*w])
end

# Check if the coordinates pass are valid
valid_coordinates(picture::HdrImage, x, y) = return((x >= 0) && (x < picture.width) && (y >= 0) && (y < picture.heigth)) 

# Save an HdrImage on a file in PFM format
#write_pfm()

end # module
