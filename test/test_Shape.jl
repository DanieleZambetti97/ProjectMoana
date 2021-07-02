using ProjectMoana

sphere = Sphere()
ray1 = Ray(Point(0,0,2), Vec(0,0,-1))
intersection1 = ray_intersection(sphere,ray1)

ray2 = Ray(Point(2,0,0), Vec(-1,0,0))
intersection2 = ray_intersection(sphere,ray2)

ray3 = Ray(Point(0,0,0), Vec(0,1,0))
intersection3 = ray_intersection(sphere,ray3)

sphere2 = Sphere(translation(Vec(10,0,0)))
ray4 = Ray(Point(10,0,2), Vec(0,0,-1))
intersection4 = ray_intersection(sphere2,ray4)

ray5 = Ray(Point(13,0,0), Vec(-1,0,0))
intersection5 = ray_intersection(sphere2,ray5)

ray6 = Ray(Point(0,0,2), Vec(0,0,1))
intersection6 = ray_intersection(sphere,ray6)

ray7 = Ray(Point(-10,0,0), Vec(0,0,-1))
intersection7 = ray_intersection(sphere,ray7)

@testset "Shape: Sphere" begin
	@test intersection1 ≈ HitRecord(Point(0,0,1), Normal(0,0,1), Vec2D(0,0), [1.0,3.0], ray1, sphere )
	@test intersection2 ≈ HitRecord(Point(1,0,0), Normal(1,0,0), Vec2D(0,0.5), [1.0, 3.0], ray2 , sphere)
	@test intersection3 ≈ HitRecord(Point(0,1,0), Normal(0,-1,0), Vec2D(0.25,0.5), [1.0, Inf], ray3 , sphere)
	@test intersection4 ≈ HitRecord(Point(10,0,1), Normal(0,0,1), Vec2D(0,0), [1.0, 3.0], ray4, sphere2 )
	@test intersection5 ≈ HitRecord(Point(11,0,0), Normal(1,0,0), Vec2D(0,0.5), [2.0,4.0], ray5, sphere2 )
	@test nothing == intersection6
	@test nothing == intersection7
end


plane = Plane(translation(Vec(0.,0.,0.)), Material(DiffuseBRDF(CheckeredPigment(RGB(0.2, 0.7, 0.3), RGB(0.3, 0.2, 0.7), 8))))
ray1 = Ray(Point(11.5,0.3,10), Vec(0,0,-1))
intersection1 = ray_intersection(plane,ray1)
ray2 = Ray(Point(11.5,0.3,10), Vec(0,0,1))
intersection2 = ray_intersection(plane,ray2)
plane2 = Plane(rotation_x(pi/2.f0)) #plane XZ
ray3 = Ray(Point(1.1,3.2,4.0), Vec(0,-1,0))
intersection3 = ray_intersection(plane2, ray3)

@testset "Shape: Plane" begin
	@test intersection1 ≈ HitRecord(Point(11.5,0.3,0), Normal(0,0,1), Vec2D(0.5,0.3), [10.], ray1, plane )
	@test nothing == intersection2
	@test intersection3 ≈ HitRecord(Point(1.1,0.,4.0), Normal(0,1,0), Vec2D(0.1,0.), [3.2], ray3, plane2 )
end

cube = AAB()
ray1 = Ray(Point(0.5, 0.5, 0.5), Vec(1.,0.,0.))
intersection1 = ray_intersection(cube, ray1)

ray2 = Ray(Point(0.1, 2.0, 0.1), Vec(0.,-1,0.) )
intersection2 = ray_intersection(cube, ray2)

ray3 = Ray(Point(0, 0, 1.5), Vec(0,1,0))
intersection3 = ray_intersection(cube, ray3)

ray4 = Ray(Point(1.5, 1, 0), Vec(1,1,0))
intersection4 = ray_intersection(cube, ray4)

ray5 = Ray(Point(0, 0, -1), Vec(0,0,-1))
intersection5 = ray_intersection(cube, ray5)

ray6 = Ray(Point(0.5,1.5,0.), Vec(0.,-0.5,0.5))
intersection6 = ray_intersection(cube, ray6)

cube1 = AAB( translation(Vec(10., 0.0, 0.0)))
ray7 = Ray(Point(0., 0.1 , 0.1), Vec(1,0,0))
intersection7 = ray_intersection(cube1, ray7)

cube2 = AAB(translation(Vec(1., 0., 0.))*rotation_x(π/2.0))
ray8 = Ray(Point(0.0, -0.5, 0.5), Vec(1., 0., 0.))
intersection8 = ray_intersection(cube2, ray8)

@testset "Shape: AAB  " begin
	@test intersection1 ≈ HitRecord(Point(1., 0.5, 0.5), Normal(-1.0, 0.0, 0.0), Vec2D(0.625, 0.5), [0.5, Inf], ray1, cube)
	@test intersection2 ≈ HitRecord(Point(0.1, 1., 0.1), Normal(0.0, 1.0, 0.0), Vec2D(1.1/4., 0.1/3.), [1.,2.], ray2, cube )
	@test nothing == intersection3
	@test nothing == intersection4
	@test nothing == intersection5
	@test intersection6 ≈ HitRecord(Point(0.5,1.0,0.5), Normal(0.0, 1.0, 0.0), Vec2D(1.5/4., 0.5/3.), [sqrt(1/2.),sqrt(2.0)], ray6, cube )
	@test intersection7 ≈ HitRecord(Point(10.0,.1,0.1), Normal(-1.0, 0.0, 0.0), Vec2D(0.1/4., 1.9/3.), [10.0,11.0], ray7, cube1)
	@test intersection8 ≈ HitRecord( Point(1.,-0.5,0.5), Normal(-1.0, 0., 0.0), Vec2D(0.5/4., 1.5/3.), [1.0, 2.0], ray8, cube2 )
end

union = ShapeUnion(Sphere(), Sphere(translation(Vec(0.,0.,1.))))
ray1 = Ray(Point(0,0,3), Vec(0,0,-1))
intersection1 = ray_intersection(union,ray1)

ray2 = Ray(Point(2,0,0), Vec(-1,0,0))
intersection2 = ray_intersection(union,ray2)

ray4 = Ray(Point(2,0,1), Vec(-1,0,0))
intersection4 = ray_intersection(union,ray4)

ray5 = Ray(Point(0,0,3), Vec(0,0,1))
intersection5 = ray_intersection(union,ray5)

ray6 = Ray(Point(-10,0,0), Vec(0,0,-1))
intersection6 = ray_intersection(union,ray6)

union2 = ShapeUnion( Sphere(), AAB())
ray7 = Ray(Point(0.5,0.5,2), Vec(0,0,-1))
intersection7 = ray_intersection(union2,ray7)

ray8 = Ray(Point(0,0,-0.5), Vec(0,0,-1))
intersection8 = ray_intersection(union2,ray8)

@testset "Shape: Union" begin
	@test intersection1 ≈ HitRecord(Point(0,0,2), Normal(0,0,1), Vec2D(0,0), [1.0,4.0], ray1, union.shape2 )
	@test intersection2 ≈ HitRecord(Point(1,0,0), Normal(1,0,0), Vec2D(0,0.5), [1.0,3.0], ray2 , union.shape1)
	@test intersection4 ≈ HitRecord(Point(1,0,1), Normal(1,0,0), Vec2D(0,0.5), [1.0,3.0], ray4, union.shape2 )
	@test nothing == intersection5
	@test nothing == intersection6
	@test intersection7 ≈ HitRecord(Point(0.5,0.5,1), Normal(0,0,1), Vec2D(1.5/4.,1.5/3.), [1.0,Inf], ray7 , union2.shape2)
	@test intersection8 ≈ HitRecord(Point(0,0,-1), Normal(0,0,1), Vec2D(0,1), [0.5, Inf], ray8, union2.shape1 )
end
