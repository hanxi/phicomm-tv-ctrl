local skynet = require "skynet"
local puremagic = require "puremagic"
local io = io
local root = skynet.getenv "static_path" or "./static/"

local cache = setmetatable({}, { __mode = "kv"  })

local function cachefile(_, filename)
	local v = cache[filename]
	if v then
		return v
	end
	local f = io.open (root .. filename)
	if f then
		local content = f:read "a"
		f:close()
        local mimetype = "text/plain"
        if content then
            content = string.gsub(content, "%${([%w%-_]+)}", skynet.getenv)
            mimetype = puremagic.via_content(content, filename)
        end
		cache[filename] = { content, mimetype}
	else
		cache[filename] = {}
	end
    return cache[filename]
end

local staticfile = setmetatable({}, {__index = cachefile })

return staticfile
