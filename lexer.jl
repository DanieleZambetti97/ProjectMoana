#try to make a lexer

struct Token
    loc::SourceLocation
    value::Union{LiteralNumber, LiteralString, Keyword, Identifier, Symbol}
end

struct InputStream
    stream::Stream
    location::SourceLocation
    saved_char
    saved_location
    tabulation

    InputStream( stream::Stream, location::SourceLocation=SourceLocation(     ), saved_char = "", saved_location = location, tabulation = 8) = new(stream, location, saved_char, saved_location, tabulation)
end
