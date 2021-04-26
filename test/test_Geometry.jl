using ProjectMoana
## TESTING VEC METHODS ###############################################

a = Vec(1.0,2.0,3.0)
b = Vec(4.0,6.0,8.0)

@testset "Geometry Vec tests           " begin
	@test isapprox(a,a)
	@test false == isapprox(a,b)
	@test isapprox(a+b ,Vec(5.0,8.0,11.0) )
	@test isapprox(b-a ,Vec(3.0,4.0,5.0) )
	@test isapprox(2*a, Vec(2.0,4.0,6.0))
	@test isapprox(a*b, 40)
	@test isapprox(cross(a,b) , Vec(-2,4,-2))
end
## TESTING POINTS METHODS ###############################################

a = Point(1.0, 2.0, 3.0)
b = Point(4.0, 6.0, 8.0)

@testset "Geometry Point tests         " begin
	@test isapprox(a,a) == true
	@test isapprox(a,b) == false
	@test isapprox((a * 2.), Point(2.0, 4.0, 6.0)) == true
	@test isapprox((a + b), Point(5.0, 8.0, 11.0)) == true
	#@test isapprox((b - a), Vec(3.0, 4.0, 5.0)) == true #uncomment when adding Vec - Vec method
end


## TESTING TRANSFORMATION METHODS ###############################################

T1 = Transformation( [ [1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0], [9.0, 9.0, 8.0, 7.0], [6.0, 5.0, 4.0, 1.0] ],
                     [ [-3.75, 2.75, -1, 0], [4.375, -3.875, 2.0, -0.5], [0.5, 0.5, -1.0, 1.0], [-1.375, 0.875, 0.0, -0.5] ] )

T2 = Transformation( [ [3.0, 5.0, 2.0, 4.0], [4.0, 1.0, 0.0, 5.0], [6.0, 3.0, 2.0, 0.0], [1.0, 4.0, 2.0, 1.0] ],
                     [ [0.4, -0.2, 0.2, -0.6], [2.9, -1.7, 0.2, -3.1], [-5.55, 3.15, -0.4, 6.45], [-0.9, 0.7, -0.2, 1.1] ] )

T1_same = Transformation( [ [1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0], [9.0, 9.0, 8.0, 7.0], [6.0, 5.0, 4.0, 1.0] ],
						  [ [-3.75, 2.75, -1, 0], [4.375, -3.875, 2.0, -0.5], [0.5, 0.5, -1.0, 1.0], [-1.375, 0.875, 0.0, -0.5] ] )

T_expected = Transformation( [ [33.0, 32.0, 16.0, 18.0], [89.0, 84.0, 40.0, 58.0], [118.0, 106.0, 48.0, 88.0], [63.0, 51.0, 22.0, 50.0] ],
                     		 [ [-1.45, 1.45, -1.0, 0.6], [-13.95, 11.95, -6.5, 2.6], [25.525, -22.025, 12.25, -5.2], [4.825, -4.325, 2.5, -1.1] ] )

T1_homogeneous = Transformation( [ [1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0], [9.0, 9.0, 8.0, 7.0], [0.0, 0.0, 0.0, 1.0] ],
                                 [ [-3.75, 2.75, -1, 0], [5.75, -4.75, 2.0, 1.0], [-2.25, 2.25, -1.0, -2.0], [0.0, 0.0, 0.0, 1.0] ] )
       
V_expected = Vec(14.0, 38.0, 51.0)
P_expected = Point(18.0, 46.0, 58.0)
N_expected = Normal(-8.75, 7.75, -3.0)

@testset "Geometry Transofrmation tests" begin

    @test is_consistent(T1)
    @test isapprox(T1, T1_same)

    T1_same.m[1][3] += 100.0
    T1_same.invm[2][1] += 100.0

    @test isapprox(T1, T1_same) == false
    @test isapprox(T1, T1_same) == false

    @test is_consistent(T2)
    @test is_consistent(T_expected)
    @test is_consistent(T1_homogeneous)

    @test isapprox(T_expected, T1*T2)
    @test isapprox(V_expected, T1_homogeneous*Vec(1.0, 2.0, 3.0))
    @test isapprox(P_expected, T1_homogeneous*Point(1.0, 2.0, 3.0))
    @test isapprox(N_expected, T1_homogeneous*Normal(3.0, 2.0, 4.0))
    
    T1_copy = inverse(T1)
    prod = T1 * T1_copy

    @test is_consistent(T1_copy)
    @test is_consistent(prod)
    @test isapprox(prod, Transformation() )

    translation_1 = translation(Vec(1.0, 2.0, 3.0))
    translation_2 = translation(Vec(4.0, 6.0, 8.0))
    prod = translation_1 * translation_2
    expected = translation(Vec(5.0, 8.0, 11.0))

    @test is_consistent(translation_1)
    @test is_consistent(translation_2)
    @test is_consistent(prod)
    @test isapprox(expected, prod)

    @test is_consistent(rotation_x(0.1))
    @test is_consistent(rotation_y(0.1))
    @test is_consistent(rotation_z(0.1))
    @test isapprox( (rotation_x( pi/2 ) * Vec(0.0, 1.0, 0.0)) , (Vec(0.0, 0.0, 1.0)) )
    @test isapprox( (rotation_y( pi/2 ) * Vec(0.0, 0.0, 1.0)) , (Vec(1.0, 0.0, 0.0)) )
    @test isapprox( (rotation_z( pi/2 ) * Vec(1.0, 0.0, 0.0)) , (Vec(0.0, 1.0, 0.0)) )
   
    translation_1 = scaling(Vec(2.0, 5.0, 10.0))
    translation_2 = scaling(Vec(3.0, 2.0, 4.0))
    expected = scaling(Vec(6.0, 10.0, 40.0))
    
    @test is_consistent(translation_2)
    @test is_consistent(translation_1)
    @test isapprox(translation_1 * translation_2, expected)

end
