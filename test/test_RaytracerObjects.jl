ray = Ray( Point(1.0, 2.0, 3.0), Vec(6.0, 5.0, 4.0))
transformation = translation( Vec(10.0, 11.0, 12.0) ) * rotation_x(pi()/2.0)
transformed = ray.transform(transformation)
    
    @test is_close(Point(11.0, 8.0, 14.0), transformed.origin)
    @test is_close(Vec(6.0, -4.0, 5.0), transformed.dir)