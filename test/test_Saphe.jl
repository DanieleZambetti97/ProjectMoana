using ProjectMoana

sphere=Sphere()
ray1= Ray(Point(0,0,2), Vec(0,0,-1))
intersection = ray_intersection(sphere,ray1)

@testset "Sphere test" begin
	@test intersection ≈ HitRecord(Point(0,0,1), Normal(0,0,1), Vec2D(0,0), 2.0, ray1 )
end
