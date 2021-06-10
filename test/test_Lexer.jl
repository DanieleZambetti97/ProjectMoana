## Testing LEXER ##########################

stream = InputStream(IOStream("abc   \nd\nef"))

@testset "Test SceneFiles: input file" begin 
 
        @test stream.location.line_num == 1
        @test stream.location.col_num == 1

        @test read_char(stream) == "a"
        @test stream.location.line_num == 1
        @test stream.location.col_num == 2

        unread_char(stream, "A")
        @test stream.location.line_num == 1
        @test stream.location.col_num == 1

        @test read_char(stream) == "A"
        @test stream.location.line_num == 1
        @test stream.location.col_num == 2

        @test read_char(stream) == "b"
        @test stream.location.line_num == 1
        @test stream.location.col_num == 3

        @test read_char(stream) == "c"
        @test stream.location.line_num == 1
        @test stream.location.col_num == 4

        skip_whitespaces_and_comments(stream)

        @test read_char(stream) == "d"
        @test stream.location.line_num == 2
        @test stream.location.col_num == 2

        @test read_char(stream) == "\n"
        @test stream.location.line_num == 3
        @test stream.location.col_num == 1

        @test read_char(stream) == "e"
        @test stream.location.line_num == 3
        @test stream.location.col_num == 2

        @test read_char(stream) == "f"
        @test stream.location.line_num == 3
        @test stream.location.col_num == 3

        @test read_char(stream) == ""

end

