## Code for RENDEREING algorithms #############################################

abstract type Renderer
end

struct OnOff_renderer <: Renderer
    world::World
#    background_color::RGB #che in realtà non è un RGB ma il peso di ogni canale

#    OnOff_renderer(world::World; background_color=RGB(0.,0.,0.), ray) = new(world, background_color) 
    OnOff_renderer(world::World) = new(world) 
end

function OnOff_renderer(renderer, ray)
    if ray_intersection(renderer.world, ray) == nothing
        return RGB(0., 0., 0.)
    else
        return RGB(1., 1., 1.)
    end
end

function Flat_renderer(ray)
end
