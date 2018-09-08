__precompile__()

module Pages

using HTTP, JSON

import HTTP.WebSockets.WebSocket

export Endpoint, Callback, Plotly
const pathVarRegex = r"\{\w+\}"
mutable struct Endpoint
    handler::Function
    route::String
    sessions::Dict{String,WebSocket}
    regex::Regex

    function Endpoint(handler,route)
        p = new(handler,route,Dict{String,WebSocket}())
        if !ismatch(pathVarRegex, route)
            !haskey(pages,route) || warn("Page $route already exists.")
            pages[route] = p
            finalizer(p, p -> delete!(pages, p.route))
        else
            # support path variables eg. /api/person/{persion-id}/child/{child-id}
            p.regex = regex = Regex(replace(route, r"\{\w+\}", ".+"))
            !haskey(regexPages,regex) || warn("Page $route ($regex) already exists.")
            regexPages[regex] = p
            finalizer(p, p -> delete!(regexPages, p.regex))
        end
        p
    end
end
function Base.show(io::Base.IO,endpoint::Endpoint)
    print(io,"Endpoint created at $(endpoint.route).")
end
const pages = Dict{String,Endpoint}() # url => page
const regexPages = Dict{Regex,Endpoint}() # url regex => page

include("callbacks.jl")
include("server.jl")
include("api.jl")
include("displays/plotly.jl")
# include("ijulia.jl")

include("../examples/examples.jl")

end
