## Code for the LEXICAL analysis ###################################################################################
import ColorTypes: RGB
import Base.copy
WHITESPACE = " \t\n\r"
SYMBOLS = "()<>[],*"


# location of a single Char:
mutable struct SourceLocation
    file_name::String
    line_num::Int
    col_num::Int

    SourceLocation(file_name::String = "",
                   line_num::Int32 = Int32(0),
                   col_num::Int32 = Int32(0)) =
                   new(file_name, line_num, col_num)
end


# different types of Tokens:
mutable struct Stop
    loc::SourceLocation
end

mutable struct Identifier
    loc::SourceLocation
    s::Union{String, Char}
end

mutable struct LiteralString
    loc::SourceLocation
    s::String
end

mutable struct LiteralNumber
    loc::SourceLocation
    number::Float32
end

mutable struct Symbol
    loc::SourceLocation
    symbol::Char
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

# generic Token:
mutable struct Token
    loc::SourceLocation
    value::Union{LiteralNumber, LiteralString, Keyword, Identifier, Symbol, Stop}
end

"""
    InputStream(stream,
                location,
                saved_char,
                save_location,
                saved_token,
                tabulation)
It creates a Input Stream, that can be passed to the READ FUNCTION.

## Arguments:
- `stream` is the text read (IOBuffer!);
- `location` is the SourceLocation;
- `saved_char` is the currently read **Char** (functionault = '€');
- `save_location` is the location of the saved_char;
- `saved_token` is the Token associated to the saved_char (it can be a **Token** or the functionault value **Nothing**);
- `tabulation` is the number of spaces that form a tabulation (functionault = 8).
"""
mutable struct InputStream
    stream::IOBuffer
    location::SourceLocation
    saved_char::Char
    saved_location::SourceLocation
    saved_token::Union{Token, Nothing}
    tabulation::Int

    InputStream( stream::IOBuffer,
                 location::SourceLocation = SourceLocation("", Int32(1), Int32(1)),
                 saved_char = '€', 
                 saved_location = location,
                 saved_token = nothing,
                 tabulation = 8) =
                 new(stream, location, saved_char, saved_location, saved_token, tabulation)
end


# new error message to dislpay when something went wrong:
struct GrammarError <: Exception
    msg::String
    
    GrammarError(msg::String,
                 loc::SourceLocation = SourceLocation() ) =
                 new("$msg \n Stacktrace: \n in $(loc.file_name) at line $(loc.line_num) : $(loc.col_num)")
end


# function to create a copy of a SourceLocation:
copy(location::SourceLocation) = SourceLocation(location.file_name, Int32(location.line_num), Int32(location.col_num))


## FUNCTIONS ####################################################################################################################

# increment the positional indexes:
function _update_pos(stream::InputStream, ch::Char)
    if ch == '€'
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

"""
    read_char(stream::InputStream)

It reads Char one by one, updating the positional indexes.
"""
function read_char(stream::InputStream)
    
    if stream.saved_char != '€'
        ch = stream.saved_char
        stream.saved_char = '€'

    elseif eof(stream.stream)
        ch = '€'  
    else
        ch = read(stream.stream, Char)
    end

    stream.saved_location = copy(stream.location)
    _update_pos(stream, ch)

    return ch
end

"""
    unread_char(stream::InputStream, ch::Char)

After reading the Char, it has to be unread, saving the location.
"""
function unread_char(stream::InputStream, ch)
    while true
        stream.saved_char == '€' && break
    end
    stream.saved_char = ch
    stream.location = copy(stream.saved_location)
end

# ignore all the whitespaces and comments:
function skip_whitespaces_and_comments(stream::InputStream)
    ch = read_char(stream)
    while occursin(ch, WHITESPACE) || ch == '#'
        if ch == '#'
            while (read_char(stream) in ['\r', '\n', '€']) == false
                nothing               
            end
        end

        ch =read_char(stream)

        if ch == '€'
            return
        end
    end
    unread_char(stream, ch)
end

# is it a STRING?
function _parse_string_token(stream, token_location::SourceLocation)
    token = ""
    while true
        ch =read_char(stream)
        if ch == '"'
            break
        end
        if ch == '€'
            throw(GrammarError("Unterminated string", token_location))
        end
        token *= ch
    end
    return Token(token_location, LiteralString(token_location, token)) ## it returns a TOKEN!
end

# is it a FLOAT?
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
        token = parse(Float32, string(token))
    catch e
        throw(GrammarError("$(token) is an invalid floating-point number", token_location))
    end
    return Token(token_location, LiteralNumber(token_location, token)) ## it returns a TOKEN!
end

# is it a KEYWORD of a IDENTIFIER?
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
    # If it is a keyword, it must be listed in the KEYWORDS enum:
    for i in 1:length(instances(KeywordEnum))
        token == string(KeywordEnum(i)) && return Token(token_location, Keyword(token_location, KeywordEnum(i)))   
    end
    # If not it must be an IDENTIFIER:
    return Token(token_location, Identifier(token_location, token)) ## it returns a TOKEN!
    
end

"""
    read_token(stream::InputStream)

It reads all the stream, searching for the **TOKENS**!
"""
function read_token(stream::InputStream)
    if stream.saved_token != nothing
        result = stream.saved_token
        stream.saved_token = nothing
        return result
    end

    skip_whitespaces_and_comments(stream) # now there aren't spaces or comments!

    ch = read_char(stream)
    if ch == '€'
        return Stop(stream.location) # there's nothing in the file => Stop!
    end

    # Now it searches for any Token that star with the Char ch! (after saving its location)
    token_location = stream.location

    if occursin(ch, SYMBOLS)
        # It's a one-character symbol, like "(" or ","
        return Token(token_location, Symbol(token_location, ch))

    elseif ch == '"' 
        # it's a literal string (used for FILE NAMES)
        return _parse_string_token(stream, token_location)

    elseif isdigit(ch) || ch in ['+', '-', '.']
        # It's a floating-point number
        return _parse_float_token(stream, ch, token_location)

    elseif isletter(ch) || ch == '_'
        # It can be both a KEYWORD or a IDENTIFIER, thus:
        return _parse_keyword_or_identifier_token( stream, ch, token_location )

    else
        # It's some weird character, like "@` or `&`
        throw(GrammarError(stream.location, "Invalid character $ch"))
    end
    
end

"""
    unread(stream::InputStream, token::Token)

Unread the token: *look-ahead* funtion (necessary in LL(1) grammars).
"""
function unread_token(stream::InputStream, token::Token)
    if stream.saved_token == nothing 
        stream.saved_token = token
    end
end

## PARSER #########################################################################################

# auxiliary functions
assert_is_keyword(token::Token, keyword::KeywordEnum)= isa(token.value, Keyword) && token.value.keyword == keyword

assert_is_identifier(token::Token, identifier::Union{String, Char}) = isa(token.value, Identifier) && token.value.s == identifier 

assert_is_symbol(token::Token, symbol::Union{String, Char}) = occursin(symbol, SYMBOLS) && isa(token.value, ProjectMoana.Symbol) && token.value.symbol == symbol

assert_is_number(token::Token, number::Float64) = isa(token.value, LiteralNumber) && token.value.number == number 
assert_is_number(token::Token, number::Float32) = isa(token.value, LiteralNumber) && token.value.number == number 

assert_is_string(token::Token, string::Union{String, Char}) = isa(token.value, LiteralString) && token.value.s == string 

mutable struct Scene

    materials::Dict{String, Material}
    world::World
    camera::Union{Camera, Nothing}
    float_variables::Dict{String, Float32}
    overridden_variables::Set{String}

    Scene(materials::Dict{String, Material} = Dict{String, Material}(),
          world::World = World(),
          camera::Union{Camera, Nothing} = nothing,
          float_variables::Dict{String, Float32} = Dict{String, Float32}(),
          overridden_variables::Set{String} = Set{String}() ) =
          new(materials, world, camera,float_variables, overridden_variables)
end

function expect_symbol(input_file::InputStream, symbol::Char)
    token = read_token(input_file)
    try
        assert_is_symbol(token, symbol)
    catch e
        throw(GrammarError("got $token instead of $symbol", token.loc))
    end
end

function expect_keywords(input_file::InputStream, keywords::Array{KeywordEnum})
    token = read_token(input_file)
    try
        isa(token.value, Keyword)
    catch e
        throw(GrammarError("expected a keyword instead of $token", token.loc))
    end 
    try
        token.value.keyword in keywords
    catch
        throw(GrammarError("expected one of the keywords $keywords instead of $token", token.loc))
    end
    return token.value.keyword
end

function expect_number(input_file::InputStream, scene::Scene)
    token = read_token(input_file)
    if isa(token.value, LiteralNumber)
        return token.value.number
    elseif isa(token.value, Identifier)
        variable_name = token.value.s
        if haskey(scene.float_variables, variable_name) == false
            throw(GrammarError("unknown variable $token", token.loc))
        end
        return scene.float_variables[variable_name]
    end
    throw(GrammarError("got $token instead of a number", token.loc))
end


function expect_string(input_file::InputStream)

    token = input_file.read_token()

    try 
        isa(token, LiteralString) == false  
    catch e
        throw(GrammarError("got $token instead of a string", token.loc))

    return token.string
    end
end


function expect_identifier(input_file::InputStream)

    token = read_token(input_file)

    try
        isa(token, Identifier)
    catch e
        throw(GrammarError("got $token instead of an identifier", token.loc))
    end
    return token.value.s
end


function parse_vector(input_file::InputStream, scene::Scene)
    expect_symbol(input_file, '[')
    x = expect_number(input_file, scene)
    expect_symbol(input_file, ',')
    y = expect_number(input_file, scene)
    expect_symbol(input_file, ',')
    z = expect_number(input_file, scene)
    expect_symbol(input_file, ']')

    return Vec(x, y, z)
end

function parse_color(input_file::InputStream, scene::Scene)
    expect_symbol(input_file, '<')
    red = expect_number(input_file, scene)
    expect_symbol(input_file, ',')
    green = expect_number(input_file, scene)
    expect_symbol(input_file, ',')
    blue = expect_number(input_file, scene)
    expect_symbol(input_file, '>')

    return RGB(red, green, blue)
end


function parse_pigment(input_file::InputStream, scene::Scene)
    keyword = expect_keywords(input_file, [UNIFORM, CHECKERED, IMAGE])
    expect_symbol(input_file, '(')

    if keyword == UNIFORM
        color = parse_color(input_file, scene)
        result = UniformPigment(color)
    elseif keyword == CHECKERED
        color1 = parse_color(input_file, scene)
        expect_symbol(input_file, ',')
        color2 = parse_color(input_file, scene)
        expect_symbol(input_file, ',')
        num_of_steps = Int32(expect_number(input_file, scene))
        result = CheckeredPigment(color1, color2, num_of_steps)
    elseif keyword == IMAGE
        file_name = expect_string(input_file)
        image_file = open(file_name, "rb")
        image = read_pfm_image(image_file)
        result = ImagePigment(image)
    else
        throw(GrammarError("This line should be unreachable"))
    end
    expect_symbol(input_file, ')')
    return result
end

function parse_brdf(input_file::InputStream, scene::Scene)
    brdf_keyword = expect_keywords(input_file, [DIFFUSE, SPECULAR])
    expect_symbol(input_file, '(')
    pigment = parse_pigment(input_file, scene)
    expect_symbol(input_file, ')')

    if brdf_keyword == DIFFUSE
        return DiffuseBRDF(pigment)
    elseif brdf_keyword == SPECULAR
        return SpecularBRDF(pigment)
    else
        throw(GrammarError("This line should be unreachable"))
    end
end

function parse_material(input_file::InputStream, scene::Scene)
    name = expect_identifier(input_file)
    expect_symbol(input_file, '(')
    brdf = parse_brdf(input_file, scene)
    expect_symbol(input_file, ',')
    emitted_radiance = parse_pigment(input_file, scene)
    expect_symbol(input_file, ')')
    return name, Material(brdf, emitted_radiance)
end


function parse_transformation(input_file::InputStream, scene::Scene)
    result = Transformation()

    while true
        transformation_kw = expect_keywords(input_file, [
            IDENTITY,
            TRANSLATION,
            ROTATION_X,
            ROTATION_Y,
            ROTATION_Z,
            SCALING,
        ])

        if transformation_kw == IDENTITY
            nothing  # Do nothing (this is a primitive form of optimization!)
        elseif transformation_kw == TRANSLATION
            expect_symbol(input_file, '(')
            result *= translation(parse_vector(input_file, scene))
            expect_symbol(input_file, ')')
        elseif transformation_kw == ROTATION_X
            expect_symbol(input_file, '(')
            result *= rotation_x(expect_number(input_file, scene))
            expect_symbol(input_file, ')')
        elseif transformation_kw == ROTATION_Y
            expect_symbol(input_file, '(')
            result *= rotation_y(expect_number(input_file, scene))
            expect_symbol(input_file, ')')
        elseif transformation_kw == ROTATION_Z
            expect_symbol(input_file, '(')
            result *= rotation_z(expect_number(input_file, scene))
            expect_symbol(input_file, ')')
        elseif transformation_kw == SCALING
            expect_symbol(input_file, '(')
            result *= scaling(parse_vector(input_file, scene))
            expect_symbol(input_file, ')')
        end

        # We must peek the next token to check if there is another transformation that is being
        # chained or if the sequence ends. Thus, this is a LL(1) parser.
        next_kw = read_token(input_file)
        if (isa(next_kw.value, Symbol) && (next_kw.value.symbol == '*')) == false
            # Pretend you never read this token and put it back!
            unread_token(input_file, next_kw)
            break
        end
    end
    return result
end


function parse_sphere(input_file::InputStream, scene::Scene)
    expect_symbol(input_file, '(')

    material_name = expect_identifier(input_file)
    if haskey(scene.materials, material_name) == false
        # We raise the exception here because input_file is pointing to the end of the wrong identifier
        throw(GrammarError(input_file.location, "unknown material $material_name"))
    end
    expect_symbol(input_file, ',')
    transformation = parse_transformation(input_file, scene)
    expect_symbol(input_file, ')')

    return Sphere(transformation, scene.materials[material_name])
end

function parse_plane(input_file::InputStream, scene::Scene)
    expect_symbol(input_file, '(')

    material_name = expect_identifier(input_file)
    if haskey(scene.materials, material_name) == false
        # We raise the exception here because input_file is pointing to the end of the wrong identifier
        throw(GrammarError(input_file.location, "unknown material $material_name"))
    end
    expect_symbol(input_file, ',')
    transformation = parse_transformation(input_file, scene)
    expect_symbol(input_file, ')')

    return Plane(transformation, scene.materials[material_name])
end


function parse_camera(input_file::InputStream, scene::Scene)
    expect_symbol(input_file, '(')
    type_kw = expect_keywords(input_file, [PERSPECTIVE, ORTHOGONAL])
    expect_symbol(input_file, ',')
    transformation = parse_transformation(input_file, scene)
    expect_symbol(input_file, ',')
    aspect_ratio = expect_number(input_file, scene)
    expect_symbol(input_file, ',')
    distance = expect_number(input_file, scene)
    expect_symbol(input_file, ')')

    if type_kw == PERSPECTIVE
        result = PerspectiveCamera(aspect_ratio, transformation, distance)
    elseif type_kw == ORTHOGONAL
        result = OrthogonalCamera(aspect_ratio, transformation)

    return result
    end
end


function parse_scene(input_file::InputStream, variables::Dict{String, Float32} = Dict{String, Float32}() )
    """Read a scene description from a stream and return a :class:`.Scene` object"""
    scene = Scene()
    scene.float_variables = copy(variables)
    scene.overridden_variables = Set{String}() ################## nooooooooooo

    while true
        what = read_token(input_file)
        if isa(what, Stop)
            break
        end
        if isa(what.value, Keyword) == false
            throw(GrammarError("expected a keyword instead of $what", what.loc))
        end
        if what.value.keyword == FLOAT
            variable_name = expect_identifier(input_file)

            # Save this for the error message
            variable_loc = input_file.location

            expect_symbol(input_file, '(')
            variable_value = expect_number(input_file, scene)
            expect_symbol(input_file, ')')

            if haskey(scene.float_variables, variable_name) == true && haskey(scene.overridden_variables, variable_name) == false
                throw(GrammarError(variable_loc, "variable «$variable_name» cannot be refunctionined"))
            end

            if (variable_name in scene.overridden_variables) == false
                # Only functionine the variable if it was not functionined by the user *outside* the scene file
                # (e.g., from the command line)
                scene.float_variables[variable_name] = variable_value
            end

        elseif what.value.keyword == SPHERE
            add_shape(scene.world,parse_sphere(input_file, scene))
        elseif what.value.keyword == PLANE
            add_shape(scene.world, parse_plane(input_file, scene))
        elseif what.value.keyword == CAMERA
            if scene.camera != nothing
                throw(GrammarError(what.location, "You cannot functionine more than one camera"))
            end
            scene.camera = parse_camera(input_file, scene)
        elseif what.value.keyword == MATERIAL
            name, material = parse_material(input_file, scene)
            scene.materials[name] = material
        end
    end

    return scene
end
