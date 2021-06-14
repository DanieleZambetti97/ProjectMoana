WHITESPACE = " \t\n\r"
SYMBOLS = "()<>[],*"

mutable struct SourceLocation
    file_name::String
    line_num::Int
    col_num::Int

    SourceLocation(file_name::String = "", line_num::Int32 = Int32(0), col_num::Int32 = Int32(0)) = new(file_name, line_num, col_num)
end
mutable struct Stop
    loc::SourceLocation
end

mutable struct Identifier
    loc::SourceLocation
    s::String
end

mutable struct LiteralString
    loc::SourceLocation
    s::String
end

mutable struct LiteralNumber
    loc::SourceLocation
    value::Float32
end

mutable struct Symbol
    loc::SourceLocation
    symbol::String
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
    saved_char::String
    saved_location::SourceLocation
    tabulation::Int

    InputStream( stream::IOBuffer, location::SourceLocation = SourceLocation("", Int32(1), Int32(1)), saved_char = "", saved_location = location, tabulation = 8) = new(stream, location, saved_char, saved_location, tabulation)
end

struct GrammarError <: Exception
    msg::String
    
    GrammarError(loc::SourceLocation, msg::String) = new("$msg\n Stacktrace:\n in $(loca.file_name) at line $(loc.line_num) : $(loc.col_num)")
end


copy(location::SourceLocation) = SourceLocation(location.file_name, Int32(location.line_num), Int32(location.col_num))



function _update_pos(stream::InputStream, ch::String)
    if ch == ""
        return
    elseif ch == "\n"
        stream.location.line_num += 1
        stream.location.col_num = 1
    elseif ch == "\t"
        stream.location.col_num += stream.tabulations
    else
        stream.location.col_num += 1
    end
end


function read_char(stream::InputStream)
    
    if stream.saved_char != ""
        ch = stream.saved_char
        stream.saved_char = ""

    elseif eof(stream.stream)
        ch = ""  
    else
        ch = String([read(stream.stream, UInt8)])
    end

    stream.saved_location = copy(stream.location)
    _update_pos(stream, ch)

    return ch
end

function unread_char(stream::InputStream, ch)
    while true
        stream.saved_char == "" && break
    end
    stream.saved_char = ch
    stream.location = copy(stream.saved_location)
end

function skip_whitespaces_and_comments(stream::InputStream)
    ch = read_char(stream)
    while occursin(ch, WHITESPACE) || ch == "#"
        if ch == "#"
            while (read_char(stream) in ["\r", "\n", ""]) == false
                nothing               
            end
        end

        ch =read_char(stream)

        if ch == ""
            return
        end
    end
    unread_char(stream, ch)
end

function _parse_string_token(stream, token_location::SourceLocation)
    token = ""
    while true
        ch =read_char(stream)
        if ch == "\""
            break
        end
        if ch == ""
            throw(GrammarError(token_location, "Unterminated string"))
        end
        token *= ch
    end
    return LiteralString(token_location, token)
end

function _parse_float_token(stream, first_char::String, token_location::SourceLocation)
    token = first_char
    while true
        ch = read_char(stream)
        if (isdigit(ch) || ch == "." || ch in ["e", "E"]) == false
            unread_char(stream, ch)
            break
        end
        token += ch
    end

    try
        value = Float32(token)
    catch e
        throw(GrammarError(token_location, "$(token) is an invalid floating-point number"))
    end

    return LiteralNumber(token_location, value)
end

function _parse_keyword_or_identifier_token(stram, first_char::String, token_location::SourceLocation)
    token = first_char
    while true
        ch = read_char(stream)
        # Note that here we do not call "isalpha" but "isalnum": digits are ok after the first character
        if (isletter(ch) || isdigit(ch) || ch == "_") == false
            unread_char(stream, ch)
            break
        end
        token *= ch
    end
    try
        # If it is a keyword, it must be listed in the KEYWORDS dictionary
        return KeywordToken(token_location, KEYWORDS[token])
    catch e
        # If we got KeyError, it is not a keyword and thus it must be an identifier
        return IdentifierToken(token_location, token)
    end
end

function read_token(stream::InputStream)

    skip_whitespaces_and_comments(stream)

    # At this point we"re sure that ch does *not* contain a whitespace character
    ch = read_char(stream)
    if ch == ""
        # No more characters in the file, so return a StopToken
        return Stop(stream.location)
    end

    # At this point we must check what kind of token begins with the "ch" character 
    # (which has been put back in the stream with self.unread_char). First,
    # we save the position in the stream
    token_location = stream.location

    if ch in SYMBOLS
        # One-character symbol, like "(" or ","
        return Symbol(token_location, ch)
    elseif ch == "\""
        # A literal string (used for file names)
        return _parse_string_token(stream, token_location)
    elseif isdigit(ch) || ch in ["+", "-", "."]
        # A floating-point number
        return _parse_float_token(stream, ch, token_location)
    elseif isletter(ch) || ch == "_"
        # Since it begins with an alphabetic character, it must either be a keyword
        # or a identifier
        return _parse_keyword_or_identifier_token( stream, ch, token_location )
    else
        # We got some weird character, like "@` or `&`
        throw(GrammarError(stream.location, "Invalid character $ch"))
    end
end

