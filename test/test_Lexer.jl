## Testing LEXER ###################################################################################################

stream = InputStream(IOBuffer("abc   \nd\nef"))

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

        @test read_char(stream) == '0'

end

##############################################################################################

stream2 = IOBuffer("""
   # This is a comment
   # This is another comment
   FLOAT a (13.0) 
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
        @test assert_is_number(read_token(infile), 13.)
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

stream = IOBuffer("""
        float clock(150)

        material sky_material(
                diffuse(uniform(<0, 0, 0>)),
                uniform(<0.7, 0.5, 1>)
        )

        # Here is a comment

        material ground_material(
                diffuse(checkered(<0.3, 0.5, 0.1>,
                                <0.1, 0.2, 0.5>, 4)),
                uniform(<0, 0, 0>)
        )

        material sphere_material(
                specular(uniform(<0.5, 0.5, 0.5>)),
                uniform(<0, 0, 0>)
        )

        plane (sky_material, translation([0, 0, 100]) * rotation_y(clock))
        plane (ground_material, identity)

        sphere(sphere_material, translation([0, 0, 1]))

        camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 2.0)
        """)

scene = parse_scene(input_file=InputStream(stream))

# Check that the float variables are ok

@testset "Test Scenefiles: Parser:" begin
        @test len(scene.float_variables) == 1
        @test "clock" in scene.float_variables
        @test scene.float_variables["clock"] == 150.0
        @test length(scene.materials) == 3

        @test haskey(scene.materials, "sphere_material")
        @test haskey(scene.materials, "sky_material")
        @test haskey(scene.materials, "ground_material")
end

sphere_material = scene.materials["sphere_material"]
sky_material = scene.materials["sky_material"]
ground_material = scene.materials["ground_material"]


@testset "Test SceneFiles: Parser" begin
        @test occursin(sky_material.brdf, DiffuseBRDF)
        @test occursin(sky_material.brdf.pigment, UniformPigment)
        @test sky_material.brdf.pigment.color ≈ RGB(Float32(0), Float32(0), Float32(0))

        @test occursin(ground_material.brdf, DiffuseBRDF)
        @test occursin(ground_material.brdf.pigment, CheckeredPigment)
        @test ground_material.brdf.pigment.color1 ≈ (RGB(0.3f0, 0.5f0, 0.1f0))
        @test ground_material.brdf.pigment.color2 ≈ (RGB(0.1f0, 0.2f0, 0.5f0))
        @test ground_material.brdf.pigment.num_of_steps == 4

        
end












@test isinstance(sphere_material.brdf, SpecularBRDF)
@test isinstance(sphere_material.brdf.pigment, UniformPigment)
@test sphere_material.brdf.pigment.color \approx (Color(0.5, 0.5, 0.5))

@test isinstance(sky_material.emitted_radiance, UniformPigment)
@test sky_material.emitted_radiance.color \approx (Color(0.7, 0.5, 1.0))
@test isinstance(ground_material.emitted_radiance, UniformPigment)
@test ground_material.emitted_radiance.color \approx (Color(0, 0, 0))
@test isinstance(sphere_material.emitted_radiance, UniformPigment)
@test sphere_material.emitted_radiance.color \approx (Color(0, 0, 0))

# Check that the shapes are ok

@test len(scene.world.shapes) == 3
@test isinstance(scene.world.shapes[0], Plane)
@test scene.world.shapes[0].transformation \approx (translation(Vec(0, 0, 100)) * rotation_y(150.0))
@test isinstance(scene.world.shapes[1], Plane)
@test scene.world.shapes[1].transformation \approx (Transformation())
@test isinstance(scene.world.shapes[2], Sphere)
@test scene.world.shapes[2].transformation \approx (translation(Vec(0, 0, 1)))

# Check that the camera is ok

@test isinstance(scene.camera, PerspectiveCamera)
@test scene.camera.transformation \approx (rotation_z(30) * translation(Vec(-4, 0, 1)))
@test pytest.approx(1.0) == scene.camera.aspect_ratio
@test pytest.approx(2.0) == scene.camera.screen_distance

def test_parser_undefined_material(self):
# Check that unknown materials raises a GrammarError
stream = StringIO("""
plane(this_material_does_not_exist, identity)
""")

try:
        _ = parse_scene(input_file=InputStream(stream))
        @test False, "the code did not throw an exception"
except GrammarError:
        pass

def test_parser_double_camera(self):
# Check that defining two cameras in the same file raises a GrammarError
stream = StringIO("""
camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 1.0)
camera(orthogonal, identity, 1.0, 1.0)
""")

try:
        _ = parse_scene(input_file=InputStream(stream))
        @test False, "the code did not throw an exception"
except GrammarError:
        pass