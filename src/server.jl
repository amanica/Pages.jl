# Browser Window (Borrowed from Blink.jl)
@static if is_apple()
    launch(x) = run(`open $x`)
elseif is_linux()
    launch(x) = run(`xdg-open $x`)
elseif is_windows()
    launch(x) = run(`cmd /C start $x`)
end

# const connections = Dict{Int,WebSocket}() # WebSocket.id => WebSocket
const conditions = Dict{String,Condition}()
conditions["connected"] = Condition()
conditions["unloaded"] = Condition()

Endpoint("/pages.js") do request::HTTP.Request
    readstring(joinpath(dirname(@__FILE__),"pages.js"))
end

# ws = WebSocketHandler() do request::Request, client::WebSocket
#     while true
#         msg = JSON.parse(String(read(client)))
#         route = msg["route"]
#         if !haskey(pages[route].sessions,client.id)
#             pages[route].sessions[client.id] = client
#         end
#         haskey(msg,"args") ? callbacks[msg["name"]].callback(client,msg["args"]) : callbacks[msg["name"]].callback(client)
#     end
# end

function start(p = 8000)
    global port = p
    HTTP.listen(ip"127.0.0.1",p) do request::HTTP.Request
        route = request.target
        if haskey(pages,route)
            response = pages[route].handler(request)
        elseif haskey(public,dirname(route))
            response = public[dirname(route)].handler(request)
        else
            response = HTTP.Response(404,"Not Found")
        end
        return response isa HTTP.Response ?
               response :
               HTTP.Response(200, response)
    end
end
