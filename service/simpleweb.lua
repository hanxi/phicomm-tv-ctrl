local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local staticfile = require "staticfile"

local table = table
local string = string

local handler
local mode = ...

if mode == "agent" then

local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        if err ~= sockethelper.socket_error then
            skynet.error(string.format("fd = %d, %s", id, err))
        end
    end
end

local base_url = skynet.getenv("base_url") or ''
skynet.start(function()
	handler = assert(skynet.uniqueservice "handler")
    skynet.dispatch("lua", function (_,_,id)
        socket.start(id)
        -- limit request body size to 8192 (you can pass nil to unlimit)
        local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id))
        if code then
            if code ~= 200 then
                response(id, code)
            else
                local action, query = urllib.parse(url)
                if base_url ~= '' then
                    action = action:gsub(base_url, '')
                end
                if action == "/" then
                    action = "/static/index.html"
                end
                local offset = action:find("/",2,true)
                if offset then
                    local path = action:sub(1,offset-1)
                    local filename = action:sub(offset+1)
                    if path == "/static" then
                        local sfile = staticfile[filename]
                        local content = sfile[1]
                        local mimetype = sfile[2]
                        if content then
                            response(id, 200, content, {["Content-Type"] = mimetype})
                        else
                            response(id, 404, "404 Not found")
                        end
                    else
                        response(id, 404, "404 Not found")
                    end
                else
                    local q = {}
                    if query then
                        q = urllib.parse_query(query)
                    end
                    local m = method:lower()
                    local a = action:sub(2)
                    local func_name = string.format("%s_%s", m, a)
                    local c, ret = skynet.call(handler, "lua", func_name, q, header, body)
                    if ret == nil then
                        ret = c
                        c = 200
                    end
                    response(id, c, ret)
                end
            end
        else
            if url == sockethelper.socket_error then
                skynet.error("socket closed")
            else
                skynet.error(url)
            end
        end
        socket.close(id)
    end)
end)

else

skynet.start(function()
    local agent = {}
    for i= 1, 20 do
        agent[i] = skynet.newservice(SERVICE_NAME, "agent")
    end

    local http_port = skynet.getenv("http_port")
    local balance = 1
    local id = socket.listen("0.0.0.0", http_port)
    skynet.error("Listen web port:", http_port)
    socket.start(id , function(id, addr)
        -- skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
        skynet.send(agent[balance], "lua", id)
        balance = balance + 1
        if balance > #agent then
            balance = 1
        end
    end)
end)

end
