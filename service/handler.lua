local skynet = require "skynet"
local httpc = require "http.httpc"
require "skynet.manager"

local CMD = {}

local host = skynet.getenv("tv_host")
local url = "/v1/keyevent"
function CMD.post_keyevent(query, header, body)
    return httpc.request("POST", host, url, nil, header, body)
end

function CMD.get_host()
    return host
end

skynet.start(function()
	httpc.timeout = 100	-- set timeout 1 second
    skynet.register ".handler"
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            skynet.ret(skynet.pack("404 Not found", 404))
        end
    end)
end)

