## Code for RENDEREING algorithms #############################################

function OnOff_renderer(ray::Ray, world::World; on_color::RGB=RGB(1.,1.,1.), off_color::RGB=RGB(0.,0.,0.))
    if ray_intersection(world, ray) == nothing
        return off_color
    else
        return on_color
    end
end


function Flat_renderer(ray::Ray, world::World; background_color=RGB(0.,0.,0.) )
    hit_record = ray_intersection(world, ray)
    if hit_record == nothing
        return background_color
    else
        material = hit_record.shape.material
        return get_color(material.brdf.pigment, hit_record.surface_point) + get_color(material.emitted_radiance, hit_record.surface_point)
    end
end


function PathTracer_renderer()
end






abstract type Renderer end 

struct Renederer_OnOff <: Renderer
    world::World
    background_color :: RGB 

    Renederer_Flat(world::World, background_color::RGB=RGB(0.,0.,0.) ) = new(world, background_color) 
end

struct Renederer_Flat <: Renderer
    world::World
    background_color :: RGB 

    Renederer_Flat(world::World, background_color::RGB=RGB(0.,0.,0.) ) = new(world, background_color) 
end

struct Renderer_PathTracer <: Renderer
end
