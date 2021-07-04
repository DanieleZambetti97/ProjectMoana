import ColorTypes: RGB

## Code for PIGMENT type and its sons ##################################################

abstract type Pigment end

## Unfirom Pigment

"""
    UniformPigment(color)

It creates a uniform pigment, where color is a RGB type.
"""
struct UniformPigment <: Pigment
    color::RGB

    UniformPigment(color::RGB) = new(color)
end

Base.:≈(pig1::UniformPigment, pig2::UniformPigment) = pig1.color ≈ pig2.color


"""
    get_color(un_pig, Vec2D)
    get_color(im_pig, Vec2D)
    get_color(check_pig, Vec2D)

It returns the **COLOR** of the pixel with coordinates (u,v) of the Vec2D given. It works with every pigment implemented 
(uniform, image, checkered).
"""
get_color(un_pig::UniformPigment, vec2d::Vec2D) = return un_pig.color


## Image Pigment

"""
    ImagePigment(img)

It creates a Image Pigment, where img is HdrImage type. Thus, the image is transferred to the pixels.
"""
struct ImagePigment <: Pigment
    image::HdrImage

    ImagePigment(img::HdrImage) = new(img)
end
   
function get_color(im_pig:: ImagePigment, uv::Vec2D)
    col = convert(Int64, floor(uv.u * im_pig.image.width +1))
    row = convert(Int64, floor(uv.v * im_pig.image.height +1))

    if col >= im_pig.image.width
        col = im_pig.image.width
    end

    if row >= im_pig.image.height
        row = im_pig.image.height
    end

    return im_pig.image.pixels[get_pixel(im_pig.image, col, row)] 
end


## Checkered Pigment

"""
    CheckeredPigment(color1, color2, n_steps)

It creates a Checkered Pigment, useful for debugging. 
If not defined n_steps = 10.
"""
struct CheckeredPigment <: Pigment
    color1::RGB
    color2::RGB
    n_steps::Number

    CheckeredPigment(color1, color2, n_steps=10) = new(color1, color2, n_steps)
end

Base.:≈(pig1::CheckeredPigment, pig2::CheckeredPigment) = pig1.color1 ≈ pig2.color1 && pig1.color2 ≈ pig2.color2 && pig1.n_steps ≈ pig2.n_steps

function get_color(check_pig::CheckeredPigment, uv::Vec2D)
    int_u = convert(Int64, floor(uv.u * check_pig.n_steps))
    int_v = convert(Int64, floor(uv.v * check_pig.n_steps))

    if int_u % 2 == int_v % 2
        return check_pig.color1
    else
        return check_pig.color2
    end 
end


## Code for BRDF type and its sons #####################################################

abstract type BRDF end
eval(brdf::BRDF, n::Normal, in_dir::Vec, out_dir::Vec, uv::Vec2D) = return RGB(0.f0, 0.f0, 0.f0)
scatter_ray(brdf::BRDF, pcg::PCG, incoming_dir::Vec, interaction_point::Point, normal::Normal, depth) = return "Abstract method, not implemented"

"""
    DiffuseBRDF(pigment, r)

It creates a Diffuse BRDF, where _r_ is the reflectance of the surface.
If not defined:
- pigment = UniformPigment(RGB(1.,1.,1.));
- r = 1.
"""
struct DiffuseBRDF <: BRDF
    pigment::Pigment
    reflectance::Number

    DiffuseBRDF(pigment::Pigment = UniformPigment(RGB(1.,1.,1.)),
                reflectance::Number = 1. ) =
                new(pigment, reflectance)
end

Base.:≈(brdf1::DiffuseBRDF, brdf2::DiffuseBRDF) = brdf1.pigment ≈ brdf2.pigment && brdf1.reflectance ≈ brdf2.reflectance

eval(brdf::DiffuseBRDF, n::Normal, in_dir::Vec, out_dir::Vec, uv::Vec2D) = return brdf.pigment.get_color(uv) * (brdf.reflectance / π)

function scatter_ray(brdf::DiffuseBRDF, pcg::PCG, incoming_dir::Vec, interaction_point::Point, normal::Normal, depth)
    e1, e2, e3 = create_onb(normal)
    cos_theta_sq = pcg_randf(pcg)
    cosθ, sinθ = sqrt(cos_theta_sq), sqrt(1.0 - cos_theta_sq)
    ϕ = 2.0 * π * pcg_randf(pcg)
    return Ray( interaction_point, e1*cos(ϕ)*cosθ + e2*sin(ϕ)*cosθ + e3*sinθ, 1.0e-10, Inf, depth)
end

"""
    SpecularBRDF(pigment, r)

It creates a Diffuse BRDF, where _r_ is the reflectance of the surface.
If not defined:
- pigment = UniformPigment(RGB(1.f0,1.f0,1.f0));
- r = 1.
"""
struct SpecularBRDF <: BRDF   
    pigment::Pigment

    SpecularBRDF(pigment::Pigment = UniformPigment(RGB(1.,1.,1.)) ) = new(pigment)    
end

Base.:≈(brdf1::SpecularBRDF, brdf2::SpecularBRDF) = brdf1.pigment ≈ brdf2.pigment

#eval(brdf::SpecularBRDF, n::Normal, in_dir::Vec, out_dir::Vec, uv::Vec2D) = return brdf.pigment.get_color(uv) * (brdf.reflectance / π)
##in realtà non serve main

function scatter_ray(brdf::SpecularBRDF, pcg::PCG, incoming_dir::Vec, interaction_point::Point, normal::Normal, depth)
    ray_dir = normalize(Vec(incoming_dir.x, incoming_dir.y, incoming_dir.z))
    normal = normalize(toVec(normal))
    dot_prod = normal * ray_dir

    return Ray(interaction_point, ray_dir - normal * 2 * dot_prod, 1e-10, Inf, depth)
end

## Code for MATERIAL and its sons #####################################################

function LightSource(x::RGB)
    if x == RGB()
        return false
    else
        return true
    end
end

"""
    Material(brdf, e_r)

It creates a Material, where brdf is a generic BRDF and e_r is the emitted radiance of the surface (Pigment type).
If not defined:
- brdf = DiffuseBRDF();
- e_r = UniformPigment(RGB(0.f0,0.f0,0.f0)).
"""
struct Material
    brdf::BRDF
    emitted_radiance::Pigment
    is_light_source:: Bool

    Material(brdf::BRDF = DiffuseBRDF(),
             emitted_radiance::Pigment = UniformPigment(RGB(0.f0,0.f0,0.f0)),
             is_light_source::Bool = LightSource(emitted_radiance.color) ) =
             new(brdf, emitted_radiance, is_light_source)
end 

Base.:≈(M1::Material,M2::Material) = M1.brdf ≈ M2.brdf && M1.emitted_radiance ≈ M2.emitted_radiance



