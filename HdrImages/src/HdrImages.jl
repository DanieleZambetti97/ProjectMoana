module HdrImages

import Colors
import ColorTypes
import Base

greet() = print("Hello World!")

mutable struct HdrImage
    width::Int
    height::Int
    pixels::Array{ColorTypes.RGB, 1}
    HdrImage(w, h) = new(w, h, [ColorTypes.RGB() for i in 1:h*w]) #incredibile, se implementi un costruttore interno julia rimuove il suo 
    HdrImage(w, h, array) = new(w, h, array)                      #costruttore di default quindi devi rimplementarlo te
end

# Check if the coordinates pass are valid
valid_coordinates(img::HdrImage, x, y) = return((x >= 0) && (x < img.width) && (y >= 0) && (y < img.height))

# Check that the (x,y) pixel of the image is in the right place in the linear array pixels of the struct
pixel_offset(img::HdrImage, x, y) = (y-1) * img.height + x

# Save an HdrImage on a file in PFM format
#write_pfm()

end # module
