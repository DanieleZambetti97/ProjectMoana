## Testing LEXER ##########################

stream = InputStream(IOBuffer("abc   \nd\nef"))

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

######################################################################

function assert_is_keyword(token::Token, keyword::KeywordEnum) 
        isa(token.value, Keyword) || "Token '$(token.value)' is not a KeywordToken"
        token.value.keyword == keyword  || "Token '$(token.value)' is not equal to keyword '$(keyword)'"
   end
   
   function assert_is_identifier(token::Token, identifier::String) 
        isa(token.value, Identifier) || "Token '$(token.value)' is not a IdentifierToken"
        token.value.identifier == identifier || "Expecting identifier '$(identifier)' instead of '$(token.value)'"
   end
   
   function assert_is_symbol(token::Token, symbol::String) 
        isa(token.value, Symbol) || "Token '$(token.value)' is not a SymbolToken"
        token.value.symbol == symbol || "Expecting symbol '$(symbol)' instead of '$(token.value)'"
   end
   
   function assert_is_number(token::Token, number::Float64) 
        isa(token.value, LiteralNumber) || "Token '$(token.value)' is not a LiteralNumberToken"
        token.value.number == number || "Token '$(token.value)' is not equal to number '$(number)'"
   end
   
   function assert_is_string(token::Token, string::String) 
        isa(token.value, LiteralString) || "Token '$(token.value)' is not a StringToken"
        token.value.string == string || "Token '$(token.value)' is not equal to string '$(string)'"
   end



stream2 = IOBuffer("""
   # This is a comment
   # This is another comment
   NEW MATERIAL sky_material(
       DIFFUSE(image("my file.pfm")),
       <5.0, 500.0, 300.0>
   ) # Comment at the end of the line
""")

infile = InputStream(stream2)

@testset "Test SceneFiles: read token" begin
        
        @test assert_is_keyword(read_token(infile), KeywordEnum(1))
        # @test assert_is_keyword(read_token(infile), KeywordEnum(2))
        # @test assert_is_identifier(read_token(infile), "sky_material")
        # @test assert_is_symbol(read_token(infile), "(")
        # @test assert_is_keyword(read_token(infile), KeywordEnum.DIFFUSE)
        # @test assert_is_symbol(read_token(infile), "(")
        # @test assert_is_keyword(read_token(infile), KeywordEnum.IMAGE)
        # @test assert_is_symbol(read_token(infile), "(")
        # @test assert_is_string(read_token(infile), "my file.pfm")
        # @test assert_is_symbol(read_token(infile), ")")
end

