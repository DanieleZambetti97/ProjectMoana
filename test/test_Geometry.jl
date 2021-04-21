using ProjectMoana
## TESTING VEC METHODS ###############################################

a = Vec(1.0,2.0,3.0)
b = Vec(4.0,6.0,8.0)

@testset "Geometry Vec tests  " begin
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

@testset "Geometry Point tests" begin
        @test isapprox(a,a) == true
        @test isapprox(a,b) == false
        @test isapprox((a * 2.), Point(2.0, 4.0, 6.0)) == true
        @test isapprox((a + b), Point(5.0, 8.0, 11.0)) == true
        #@test isapprox((b - a), Vec(3.0, 4.0, 5.0)) == true #uncomment when adding Vec - Vec method
end


## TESTING TRANSFORMATION METHODS #######################################

m = [[1.0, 2.0, 3.0, 4.0],
     [5.0, 6.0, 7.0, 8.0],
     [9.0, 9.0, 8.0, 7.0],
     [6.0, 5.0, 4.0, 1.0]]
invm = [[-3.75, 2.75, -1, 0],
        [4.375, -3.875, 2.0, -0.5],
        [0.5, 0.5, -1.0, 1.0],
        [-1.375, 0.875, 0.0, -0.5]]

m3 = [[1.0, 2.0, 3.0, 4.0],
     [5.0, 6.0, 10000.0, 8.0],
     [9.0, 9.0, 8.0, 7.0],
     [6.0, 5.0, 4.0, 1.0]]
invm3 = [[-3.75, 2.75, -1, 0],
        [4.375, -3.875, 2.0, -0.5],
        [0.5, 0.5, -1.0, 1.0],
        [-1.375, 0.875, 0.0, -0.5]]

m4 = [[1.0, 2.0, 3.0, 4.0],
      [5.0, 6.0, 7.0, 8.0],
      [9.0, 9.0, 8.0, 7.0],
      [6.0, 5.0, 4.0, 1.0]]
invm4 = [[-3.75, 2.75, -1, 0],
         [4.375, -3.875, 2.0, -0.5],
         [0.5, 0.5, -1000.0, 1.0],
         [-1.375, 0.875, 0.0, -0.5]]

m5 = [[3.0, 5.0, 2.0, 4.0],
      [4.0, 1.0, 0.0, 5.0],
      [6.0, 3.0, 2.0, 0.0],
      [1.0, 4.0, 2.0, 1.0]]
invm5 = [[0.4, -0.2, 0.2, -0.6],
         [2.9, -1.7, 0.2, -3.1],
         [-5.55, 3.15, -0.4, 6.45],
         [-0.9, 0.7, -0.2, 1.1]]

me = [[33.0, 32.0, 16.0, 18.0],
      [89.0, 84.0, 40.0, 58.0],
      [118.0, 106.0, 48.0, 88.0],
      [63.0, 51.0, 22.0, 50.0]]

invme = [[-1.45, 1.45, -1.0, 0.6],
         [-13.95, 11.95, -6.5, 2.6],
         [25.525, -22.025, 12.25, -5.2],
         [4.825, -4.325, 2.5, -1.1]]

m1 = Transformation(m, invm)

m2 = Transformation(deepcopy(m1.m), deepcopy(m1.invm))

m3 = Transformation(m3, invm3)

m4 = Transformation(m4, invm4)

m5 = Transformation(m5, invm5)

expected = Transformation(me, invme)

expected_v = Vec(14.0, 38.0, 51.0)
expected_p = Point(18.0, 46.0, 58.0)
expected_n = Normal(-8.75, 7.75, -3.0)

@testset "Geometry Transformation tests" begin
    @test is_consistent(m1)
    @test isapprox(m1, m2)
    @test isapprox(m1, m3) == false
    @test isapprox(m1, m4) == false
    @test is_consistent(m5)
    @test is_consistent(expected)
    @test isapprox(expected, m1*m5)
    @test isapprox(expected_v, m1*Vec(1.0, 2.0, 3.0))
    @test isapprox(expected_p, m1*Point(1.0, 2.0, 3.0))
    println(m1)
    @test isapprox(expected_n, m1*Normal(3.0, 2.0, 4.0))
    
end