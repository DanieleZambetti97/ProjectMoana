## Testing LEXER ##########################

# stream = InputStream(IOBuffer("abc   \nd\nef"))

# @testset "Test SceneFiles: input file" begin 
 
#         @test stream.location.line_num == 1
#         @test stream.location.col_num == 1

#         @test read_char(stream) == 'a'
#         @test stream.location.line_num == 1
#         @test stream.location.col_num == 2

#         unread_char(stream, 'A')
#         @test stream.location.line_num == 1
#         @test stream.location.col_num == 1

#         @test read_char(stream) == 'A'
#         @test stream.location.line_num == 1
#         @test stream.location.col_num == 2

#         @test read_char(stream) == 'b'
#         @test stream.location.line_num == 1
#         @test stream.location.col_num == 3

#         @test read_char(stream) == 'c'
#         @test stream.location.line_num == 1
#         @test stream.location.col_num == 4

#         skip_whitespaces_and_comments(stream)

#         @test read_char(stream) == 'd'
#         @test stream.location.line_num == 2
#         @test stream.location.col_num == 2

#         @test read_char(stream) == '\n'
#         @test stream.location.line_num == 3
#         @test stream.location.col_num == 1

#         @test read_char(stream) == 'e'
#         @test stream.location.line_num == 3
#         @test stream.location.col_num == 2

#         @test read_char(stream) == 'f'
#         @test stream.location.line_num == 3
#         @test stream.location.col_num == 3

#         @test read_char(stream) == '0'

# end

######################################################################

function assert_is_keyword(token::Token, keyword::KeywordEnum)
        return isa(token.value, Keyword) && token.value.keyword == keyword
end
   
function assert_is_identifier(token::Token, identifier::Union{String, Char}) 
        return isa(token.value, Identifier) && token.value.s == identifier 
end
   
function assert_is_symbol(token::Token, symbol::Union{String, Char}) 
        return isa(token.value, ProjectMoana.Symbol) && token.value.symbol == symbol
end
   
function assert_is_number(token::Token, number::Float64) 
        return isa(token.value, LiteralNumber) && token.value.number == number 
end
   
function assert_is_string(token::Token, string::Union{String, Char}) 
        return isa(token.value, LiteralString) && token.value.s == string 
end



stream2 = IOBuffer("""
   # This is a comment
   # This is another comment
   NEW MATERIAL sky_material(
       DIFFUSE(IMAGE("my file.pfm")),
       <5.0, 500.0, 300.0>
   ) # Comment at the end of the line
""")

infile = InputStream(stream2)

@testset "Test SceneFiles: read token" begin
        
        @test assert_is_keyword(read_token(infile), NEW)
        @test assert_is_keyword(read_token(infile), MATERIAL)
        @test assert_is_identifier(read_token(infile), "sky_material")
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_keyword(read_token(infile), DIFFUSE)
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_keyword(read_token(infile), IMAGE)
        @test assert_is_symbol(read_token(infile), '(')
        @test assert_is_string(read_token(infile), "my file.pfm") ## il problema è che nel Buffer originale "my file.pfm" è dentro le "" due volte!
                                                                  ## quindi il programma legge solo le sue " e si ferma.
        @test assert_is_symbol(read_token(infile), ')')
end

