module HdrImage
using Colors
using Raytracer

greet() = print("Hello World!")

struct HdrImage 
    heigth::Int
    width::Int
    pixels = [Color() for i in range(heigth*width)]
end

end # module
