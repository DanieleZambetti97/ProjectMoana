WHITESPACE = " \t\n\r"
SYMBOLS = "()<>[],*"

mutable struct SourceLocation
    file_name::String
    line_num::Int
    col_num::Int

    SourceLocation(file_name::String = "",
                   line_num::Int32 = Int32(0),
                   col_num::Int32 = Int32(0)) =
                   new(file_name, line_num, col_num)
end
mutable struct Stop
    loc::SourceLocation
end

mutable struct Identifier
    loc::SourceLocation
    s::Union{String, Char}
end

mutable struct LiteralString
    loc::SourceLocation
    s::Union{String, Char}
end

mutable struct LiteralNumber
    loc::SourceLocation
    number::Float32
end

mutable struct Symbol
    loc::SourceLocation
    symbol::Union{String, Char}
end
                   
@enum KeywordEnum begin
    NEW = 1
    MATERIAL = 2
    PLANE = 3
    SPHERE = 4
    DIFFUSE = 5
    SPECULAR = 6
    UNIFORM = 7
    CHECKERED = 8
    IMAGE = 9
    IDENTITY = 10
    TRANSLATION = 11
    ROTATION_X = 12
    ROTATION_Y = 13
    ROTATION_Z = 14
    SCALING = 15
    CAMERA = 16
    ORTHOGONAL = 17
    PERSPECTIVE = 18
    FLOAT = 19
end

mutable struct Keyword
    loc::SourceLocation
    keyword::KeywordEnum
end

mutable struct Token
    loc::SourceLocation
    value::Union{LiteralNumber, LiteralString, Keyword, Identifier, Symbol, Stop}
end

mutable struct InputStream
    stream::IOBuffer
    location::SourceLocation
    saved_char::Char
    saved_location::SourceLocation
    saved_token::Token
    tabulation::Int

    InputStream( stream::IOBuffer,
                 location::SourceLocation = SourceLocation("", Int32(1), Int32(1)),
                 saved_char = "", 
                 saved_location = location,
                 saved_token = nothing,
                 tabulation = 8) =
                 new(stream, location, saved_char, saved_location, saved_token, tabulation)
end

struct GrammarError <: Exception
    msg::String
    
    GrammarError(loc::SourceLocation, msg::String) = new("$msg\n Stacktrace:\n in $(loca.file_name) at line $(loc.line_num) : $(loc.col_num)")
end


copy(location::SourceLocation) = SourceLocation(location.file_name, Int32(location.line_num), Int32(location.col_num))



function _update_pos(stream::InputStream, ch::Char)
    if ch == '0'
        return
    elseif ch == '\n'
        stream.location.line_num += 1
        stream.location.col_num = 1
    elseif ch == '\t'
        stream.location.col_num += stream.tabulations
    else
        stream.location.col_num += 1
    end
end


function read_char(stream::InputStream)
    
    if stream.saved_char != '0'
        ch = stream.saved_char
        stream.saved_char = '0'

    elseif eof(stream.stream)
        ch = '0'  
    else
        ch = read(stream.stream, Char)
    end

    stream.saved_location = copy(stream.location)
    _update_pos(stream, ch)

    return ch
end

function unread_char(stream::InputStream, ch)
    while true
        stream.saved_char == '0' && break
    end
    stream.saved_char = ch
    stream.location = copy(stream.saved_location)
end

function skip_whitespaces_and_comments(stream::InputStream)
    ch = read_char(stream)
    while occursin(ch, WHITESPACE) || ch == '#'
        if ch == '#'
            while (read_char(stream) in ['\r', '\n', '0']) == false
                nothing               
            end
        end

        ch =read_char(stream)

        if ch == '0'
            return
        end
    end
    unread_char(stream, ch)
end

function _parse_string_token(stream, token_location::SourceLocation)
    token = '0'
    while true
        ch =read_char(stream)
        if ch == '\"'
            break
        end
        if ch == '0'
            throw(GrammarError(token_location, "Unterminated string"))
        end
        token *= ch
    end
    return Token(token_location, LiteralString(token_location, token))
end

function _parse_float_token(stream, first_char::Char, token_location::SourceLocation)
    token = first_char
    while true
        ch = read_char(stream)
        if (isdigit(ch) || ch == '.' || ch in ['e', 'E']) == false
            unread_char(stream, ch)
            break
        end
        token *= ch
    end

    try
        value = Float32(token)
    catch e
        throw(GrammarError(token_location, "$(token) is an invalid floating-point number"))
    end

    return Token(token_location, LiteralNumber(token_location, token))
end

function _parse_keyword_or_identifier_token(stream, first_char::Char, token_location::SourceLocation)
    token = first_char
    while true
        ch = read_char(stream)
 
        if (isletter(ch) || isdigit(ch) || ch == '_') == false
            unread_char(stream, ch)
            break
        end
        token *= ch
    end
    
    # If it is a keyword, it must be listed in the KEYWORDS dictionary
    for i in 1:length(instances(KeywordEnum))
        token == string(KeywordEnum(i)) && return Token(token_location, Keyword(token_location, KeywordEnum(i)))   
    end

    # If we got KeyError, it is not a keyword and thus it must be an identifier
    return Token(token_location, Identifier(token_location, token))
    
end

function read_token(stream::InputStream)
    if stream.saved_token != nothing
        result = stream.saved_token
        stream.saved_token = nothing
        return result
    end

    skip_whitespaces_and_comments(stream)

    # At this point we"re sure that ch does *not* contain a whitespace character
    ch = read_char(stream)
    if ch == '0'
        # No more characters in the file, so return a StopToken
        return Stop(stream.location)
    end

    # At this point we must check what kind of token begins with the "ch" character 
    # (which has been put back in the stream with self.unread_char). First,
    # we save the position in the stream
    token_location = stream.location

    println(ch)

    if occursin(ch, SYMBOLS)
        # One-character symbol, like "(" or ","
        return Symbol(token_location, ch)
    elseif ch == '\"' 
        # A literal string (used for file names)
        return _parse_string_token(stream, token_location)
    elseif isdigit(ch) || ch in ['+', '-', '.']
        # A floating-point number
        return _parse_float_token(stream, ch, token_location)
    elseif isletter(ch) || ch == '_'
        # Since it begins with an alphabetic character, it must either be a keyword
        # or a identifier
        return _parse_keyword_or_identifier_token( stream, ch, token_location )
    else
        # We got some weird character, like "@` or `&`
        throw(GrammarError(stream.location, "Invalid character $ch"))
    end
end

