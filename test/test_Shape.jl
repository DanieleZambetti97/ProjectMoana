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

@testset "Sphere test" begin
	@test intersection1 ≈ HitRecord(Point(0,0,1), Normal(0,0,1), Vec2D(0,0), 1.0, ray1 )
	@test intersection2 ≈ HitRecord(Point(1,0,0), Normal(1,0,0), Vec2D(0,0.5), 1.0, ray2 )
	@test intersection3 ≈ HitRecord(Point(0,1,0), Normal(0,-1,0), Vec2D(0.25,0.5), 1.0, ray3 )

	@test intersection4 ≈ HitRecord(Point(10,0,1), Normal(0,0,1), Vec2D(0,0), 1.0, ray4 )
	
	@test intersection5 ≈ HitRecord(Point(11,0,0), Normal(1,0,0), Vec2D(0,0.5), 2.0, ray5 )
	@test nothing == intersection6
	@test nothing == intersection7
end
