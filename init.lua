local path = minetest.get_modpath"stageplay"

stageplay = {}

stageplay.modpath = path
stageplay.get_translator = minetest.get_translator"stageplay"

if not table.unpack then
    table.unpack = unpack
end
function table.clone(t) 
	return {table.unpack(t)}
end

dofile(path.."/actor.lua")
dofile(path.."/api.lua")
dofile(path.."/default.lua")

print("[MOD] Stageplay API Loaded")