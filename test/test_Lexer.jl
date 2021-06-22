## Testing LEXER ###################################################################################################
import ColorTypes:RGB
stream = InputStream(IO("abc   \nd\nef"))

@testset "Test SceneFiles: input file" begin 
 
        @test stream.location.line_num == 1
        @test stream.location.col_num == 1

        @test read_char(stream) == 'a'
        @test stream.location.line_num == 1
        @test stream.location.col_num == 2

        unread_char(stream, 'A')
        @test stream.location.line_num == 1
        @test stream.location.col_num == 1

        @test read_char(stream) == 'A'
        @test stream.location.line_num == 1
        @test stream.location.col_num == 2

        @test read_char(stream) == 'b'
        @test stream.location.line_num == 1
        @test stream.location.col_num == 3

        @test read_char(stream) == 'c'
        @test stream.location.line_num == 1
        @test stream.location.col_num == 4

        skip_whitespaces_and_comments(stream)

        @test read_char(stream) == 'd'
        @test stream.location.line_num == 2
        @test stream.location.col_num == 2

        @test read_char(stream) == '\n'
        @test stream.location.line_num == 3
        @test stream.location.col_num == 1

        @test read_char(stream) == 'e'
        @test stream.location.line_num == 3
        @test stream.location.col_num == 2

        @test read_char(stream) == 'f'
        @test stream.location.line_num == 3
        @test stream.location.col_num == 3

        @test read_char(stream) == '€'

end

##############################################################################################

stream2 = IO("""
   # This is a comment
   # This is another comment
   FLOAT a (0.) 
   NEW MATERIAL sky_material(
       DIFFUSE(IMAGE("my file.pfm")),
       <5.0, 500.0, 300.0>
   )# Comment at the end of the line
""")

infile = InputStream(stream2)

@testset "Test SceneFiles: read token" begin
        @test assert_is_keyword(read_token(infile), FLOAT)
        @test assert_is_identifier(read_token(infile), 'a')
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_number(read_token(infile), 0.)
        @test assert_is_symbol(read_token(infile), ')')
        @test assert_is_keyword(read_token(infile), NEW)
        @test assert_is_keyword(read_token(infile), MATERIAL)
        @test assert_is_identifier(read_token(infile), "sky_material")
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_keyword(read_token(infile), DIFFUSE)
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_keyword(read_token(infile), IMAGE)
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_string(read_token(infile), "my file.pfm") 
        @test assert_is_symbol(read_token(infile), ')')
end

## Testing PARSER ##############################################################################################################à

stream3 = IO("""
        FLOAT clock(150)

        MATERIAL sky_material(
                DIFFUSE(UNIFORM(<0., 0., 0.>)),
                UNIFORM(<0.7, 0.5, 1>)
        )

        # Here is a comment

        MATERIAL ground_material(
                DIFFUSE(CHECKERED(<0.3, 0.5, 0.1>,
                                <0.1, 0.2, 0.5>, 4)),
                UNIFORM(<0, 0, 0>)
        )

        MATERIAL sphere_material(
                SPECULAR(UNIFORM(<0.5, 0.5, 0.5>)),
                UNIFORM(<0, 0, 0>)
        )

        PLANE (sky_material, TRANSLATION([0, 0, 100]) * ROTATION_Y(clock))
        PLANE (ground_material, IDENTITY)

        SPHERE(sphere_material, TRANSLATION([0, 0, 1]))

        CAMERA(PERSPECTIVE, ROTATION_Z(30) * TRANSLATION([-4, 0, 1]), 1.0, 2.0)
        """)

scene = parse_scene(InputStream(stream3))

# Check that the float variables are ok

@testset "Test Scenefiles: Parser:" begin
        @test length(scene.float_variables) == 1
        @test haskey(scene.float_variables, "clock")
        @test scene.float_variables["clock"] == 150.0
        @test length(scene.materials) == 3

        @test haskey(scene.materials, "sphere_material")
        @test haskey(scene.materials, "sky_material")
        @test haskey(scene.materials, "ground_material")
end

sphere_material = scene.materials["sphere_material"]
sky_material = scene.materials["sky_material"]
ground_material = scene.materials["ground_material"]


@testset "Test SceneFiles: Parser -> materials" begin
        @test isa(sky_material.brdf, DiffuseBRDF)
        @test isa(sky_material.brdf.pigment, UniformPigment)
        @test sky_material.brdf.pigment.color ≈ RGB(Float32(0), Float32(0), Float32(0))

        @test isa(ground_material.brdf, DiffuseBRDF)
        @test isa(ground_material.brdf.pigment, CheckeredPigment)
        @test ground_material.brdf.pigment.color1 ≈ (RGB(0.3f0, 0.5f0, 0.1f0))
        @test ground_material.brdf.pigment.color2 ≈ (RGB(0.1f0, 0.2f0, 0.5f0))
        @test ground_material.brdf.pigment.n_steps == 4

        @test isa(sphere_material.brdf, SpecularBRDF)
        @test isa(sphere_material.brdf.pigment, UniformPigment)
        @test sphere_material.brdf.pigment.color ≈ (RGB(0.5f0, 0.5f0, 0.5f0))

        @test isa(sky_material.emitted_radiance, UniformPigment)
        @test sky_material.emitted_radiance.color ≈ (RGB(0.7f0, 0.5f0, 1.0f0))
        @test isa(ground_material.emitted_radiance, UniformPigment)
        @test ground_material.emitted_radiance.color ≈ (RGB(0.f0, 0.f0, 0.f0))
        @test isa(sphere_material.emitted_radiance, UniformPigment)
        @test sphere_material.emitted_radiance.color ≈ (RGB(0.f0, 0.f0, 0.f0))

end


@testset "Test SceneFiles: Parser -> shapes" begin
        @test length(scene.world.shapes) == 3
        @test isa(scene.world.shapes[1], Plane)
        @test scene.world.shapes[1].transformation ≈ (translation(Vec(0, 0, 100)) * rotation_y(150.0f0))
        @test isa(scene.world.shapes[2], Plane)
        @test scene.world.shapes[2].transformation ≈ (Transformation())
        @test isa(scene.world.shapes[3], Sphere)
        @test scene.world.shapes[3].transformation ≈ (translation(Vec(0, 0, 1)))
        
end

@testset "Test SceneFiles: Parser -> camera: " begin
        @test isa(scene.camera, PerspectiveCamera)
        @test scene.camera.transformation ≈ (rotation_z(30.f0) * translation(Vec(-4, 0, 1)))
        @test scene.camera.aspect_ratio ≈ 1.f0
        @test scene.camera.distance ≈ 2.f0

end


stream4 = IO("""
PLANE(this_material_does_not_exist, IDENTITY)
""")

@testset "Test SceneFiles: Parser -> unkown material: " begin
        try 
                parse_scene(InputStream(stream4))
        catch e
                @test true #######################......
        end
end


# Check that defining two cameras in the same file raises a GrammarError
stream5 = IO("""
        CAMERA(PERSPECTIVE, ROTATION_Z(30) * TRANSLATION([-4, 0, 1]), 1.0, 1.0)
        CAMERA(ORTHOGONAL, IDENTITY, 1.0, 1.0)
        """)

@testset "Test SceneFiles: Parser -> double camera: " begin
        try
                parse_scene(InputStream(stream5))
        catch e 
                @test true
        end
end
