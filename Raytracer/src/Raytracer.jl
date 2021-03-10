module Raytracer

import ColorTypes
import Base.:+, Base.:*, Base.:≈

greet(name) = print("Hello $(name)! Moana welcomes you!")

#modifing the sum of two colors 

Base.:+(c1::ColorTypes.RGB{T}, c2::ColorTypes.RGB{T}) where {T} = ColorTypes.RGB((c1.r + c2.r), (c1.g + c2.g), (c1.b + c2.b))

end # module
