import ColorTypes: RGB
## Code for PATH TRACER algorithm #############################################

abstract type Pigment
end

abstract type BRDF
end

struct Material
    brdf::BRDF
    emitted_radiance::Pigment

    Material(;brdf::BRDF=DiffuseBRDF(), emitted_radiance::Pigment=UniformPigment(RGB(0.,0.,0.)) ) = new(brdf, emitted_radiance)
end 
Base.:≈(M1::Material,M2::Material) = M1.brdf ≈ M2.brdf && M1.emitted_radiance ≈ M2.emitted_radiance

