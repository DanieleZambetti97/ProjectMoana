import ColorTypes: RGB
## Code for PIGMENT type and its sons ##################################################

abstract type Pigment end

## Unfirom Pigment

struct UniformPigment <: Pigment
    color::RGB

    UniformPigment(color::RGB) = new(color)
end

get_color(un_pig) = return un_pig.color


## Image Pigment

struct ImagePigment <: Pigment
    image::HdrImage

    ImagePigment(img::HdrImage) = new(img)
end
   
function get_color(im_pig, uv::Vec2D)
    col = floor(uv.u * im_pig.image.width)
    row = floor(uv.v * im_pig.image.height)

    # if col >= im_pig.image.width
    #     col = im_pig.image.width - 1
    # end

    # if row >= im_pig.image.height
    #     row = im_pig.image.height - 1
    # end

    return get_pixel(im_pig.image, col, row) 
end


## Checkered Pigment

struct CheckeredPigment <: Pigment
    color1::RGB
    color2::RGB
    n_steps::Number

    CheckeredPigment(color1, color2) = new(color1, color2, 10)
    CheckeredPigment(color1, color2, n) = new(color1, color2, n)
end

function get_color(check_pig::CheckeredPigment)
    int_u = convert(Int64, floor(uv.u * check_pig.n_steps))
    int_v = convert(Int64, floor(uv.v * check_pig.n_steps))

    if int_u % 2 == int_v % 2
        return check_pig.color1
    else
        return check_pig.color2
    end 
end

Base.:≈(pig1::UniformPigment, pig2::UniformPigment) = pig1.color ≈ pig2.color
Base.:≈(pig1::CheckeredPigment, pig2::CheckeredPigment) = pig1.color1 ≈ pig2.color1 && pig1.color2 ≈ pig2.color2 && pig1.n_steps ≈ pig2.n_steps


## Code for BRDF type and its sons #####################################################

abstract type BRDF end

struct DiffuseBRDF <: BRDF
   
    pigment::Pigment
    reflectance::Number

    DiffuseBRDF() = new(UnfiromPigment(RGB(1.,1.,1.)), 1)
    DiffuseBRDF(pigment::Pigment) = new(pigment, 1)
    DiffuseBRDF(pigment::Pigment, r) = new(pigment, r)
    
end

eval(brdf::BRDF, n::Normal, in_dir::Vec, out_dir::Vec, uv::Vec2D) = return RGB(0., 0., 0.)
eval(brdf::DiffuseBRDF, n::Normal, in_dir::Vec, out_dir::Vec, uv::Vec2D) = return brdf.pigment.get_color(uv) * (brdf.reflectance / π)

Base.:≈(brdf1::DiffuseBRDF, brdf2::DiffuseBRDF) = brdf1.pigment ≈ brdf2.pigment && brdf1.reflectance ≈ brdf2.reflectance

## Code for MATERIAL and its sons #####################################################

struct Material
    brdf::BRDF
    emitted_radiance::Pigment

    Material(;brdf::BRDF=DiffuseBRDF(), emitted_radiance::Pigment=UniformPigment(RGB(0.,0.,0.)) ) = new(brdf, emitted_radiance)
end 
Base.:≈(M1::Material,M2::Material) = M1.brdf ≈ M2.brdf && M1.emitted_radiance ≈ M2.emitted_radiance

## Code for PATH TRACER algorithm #############################################
abstract type Renderer
end
