## Code for RENDEREING algorithms #############################################

## On-Off render algorithm ####################################################
struct OnOff_Renderer <: Renderer
    world::World
    on_color::RGB
    off_color::RGB
    OnOff_Renderer(world::World, on_color::RGB=RGB(1.,1.,1.), off_color::RGB=RGB(0.,0.,0.) ) = new(world, background_color) 
end

function OnOff(ray::Ray, renderer::OnOff_Renderer)
    if ray_intersection(renderer.world, ray) == nothing
        return renderer.off_color
    else
        return renderer.on_color
    end
end


## Flat render algorithm ######################################################
struct Flat_Renderer <: Renderer
    world::World
    background_color :: RGB 

    Flat_Renderer(world::World, background_color::RGB=RGB(0.,0.,0.) ) = new(world, background_color) 
end

function Flat(ray::Ray, renderer::Flat_Renderer)
    hit_record = ray_intersection(renderer.world, ray)
    if hit_record == nothing
        return background_color
    else
        material = hit_record.shape.material
        return get_color(material.brdf.pigment, hit_record.surface_point) + get_color(material.emitted_radiance, hit_record.surface_point)
    end
end


## Path tracer render algorithm ###############################################
struct PathTracer_Renderer <: Renderer
    world::World
    background_color::RGB
    pcg::PCG
    num_of_rays::Int
    max_depth::Int
    russian_roulette_limit::Int

    PathTracer_Renderer(world::World, background_color::RGB=RGB(0.,0.,0.), pcg=PCG(), num_of_rays=10, max_depth=2, russian_roulette_limit=3) = new(world, background_color, pcg, num_of_rays, max_depth, russian_roulette_limit)
end

function PathTracer(ray::Ray, rend::PathTracer_Renderer)
    if ray.depth > rend.max_depth:
        return RGB(0.0, 0.0, 0.0)
    end
    

    hit_record = ray_intersection(rend.world, ray)
    if hit_record == nothing
        return rend.background_color
    end


    hit_material = hit_record.shape.material
    hit_color = hit_material.brdf.pigment.get_color(hit_record.surface_point)
    emitted_radiance = hit_material.emitted_radiance.get_color(hit_record.surface_point)


    hit_color_lum = max(hit_color.r, hit_color.g, hit_color.b)


    # Russian roulette
    if ray.depth >= self.russian_roulette_limit:
        if self.pcg.random_float() > hit_color_lum:
            # Keep the recursion going, but compensate for other potentially discarded rays
            hit_color *= 1.0 / (1.0 - hit_color_lum)
        else:
            # Terminate prematurely
            return emitted_radiance


    cum_radiance = Color(0.0, 0.0, 0.0)
    if hit_color_lum > 0.0:  # Only do costly recursions if it's worth it
        for ray_index in range(self.num_of_rays):
            new_ray = hit_material.brdf.scatter_ray(
                pcg=self.pcg,
                incoming_dir=hit_record.ray.dir,
                interaction_point=hit_record.world_point,
                normal=hit_record.normal,
                depth=ray.depth + 1,
            )
            # Recursive call
            new_radiance = self(new_ray)
            cum_radiance += hit_color * new_radiance


    return emitted_radiance + cum_radiance * (1.0 / self.num_of_rays)
    
