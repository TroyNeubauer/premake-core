
local p = premake
print "test 1"
if not p.modules.emscripten then
	print "loading emscripten"
	dofile("_preload.lua")

	p.modules.emscripten = {}

	local emscripten = p.modules.emscripten

	emscripten._VERSION = "0.0.1"
	dofile("emcc.lua")

end

return p.modules.emscripten
