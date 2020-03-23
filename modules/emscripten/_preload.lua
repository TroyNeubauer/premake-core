
local p = premake

local api = p.api

print "starting preload"

api.addAllowed("system", "emscripten")
local osOption = p.option.get("os")
if osOption ~= nil then
	table.insert(osOption.allowed, { "emscripten",  "Emscripten" })
end
print "a"