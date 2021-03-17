module HdrImage
import Colors
import ColorTypes

greet() = print("Hello World!")

#struct that create a matrix heigth*width in which every element is a RGB color
struct HdrImage 
    heigth
    width
end

# Check if the coordinates pass are valid
valid_coordinates(HdrImage(), x, y)
    return ((x >= 0) && (x < HdrImage.width) && (y >= 0) && (y < HdrImage.height)) 

# Save an HdrImage on a file in PFM format
write_pfm()

end # module
