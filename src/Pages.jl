__precompile__()

module Pages

using HTTP, JSON

import HTTP.WebSockets.WebSocket

export Endpoint, Route, GET, POST, Callback, Plotly

struct Endpoint
    handler::Function
    route::String
    sessions::Dict{String,WebSocket}

    function Endpoint(handler,route)
        p = new(handler,route,Dict{String,WebSocket}())
        !haskey(pages,route) || warn("Page $route already exists.")
        pages[route] = p
        p
    end
end
function Base.show(io::Base.IO,endpoint::Endpoint)
    print(io,"Endpoint created at $(endpoint.route).")
end
const pages = Dict{String,Endpoint}() # url => page

router = HTTP.Router()

struct Route
    handler::Function
    method::String
    route::String

    function Route(handler,method,route)
        HTTP.register!(router,method,route,HTTP.HandlerFunction(handler))
        r = new(handler,method,route)
        !haskey(routes,route) || warn("Route $route already exists.")
        routes[route] = r
        r
    end
end
const routes = Dict{String,Route}() # url => page

GET(handler,route) = Route(handler,"GET",route)
POST(handler,route) = Route(handler,"POST",route)

include("callbacks.jl")
include("server.jl")
include("api.jl")
include("displays/plotly.jl")
# include("ijulia.jl")

include("../examples/examples.jl")

end
