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

local S = stageplay.get_translator

function stageplay.ms2s(ms)	-- utility function for converting milis to seconds
	return ms * 0.001
end

-- REGISTER FUNCTIONS --
stageplay.registered_actortypes = {}
stageplay.registered_actiontypes = {}
stageplay.registered_scenes = {}

function stageplay.register_actortype(name, def)
	local invalidchars = name:gsub("[a-zA-Z0-9_:]", "")
	
	if invalidchars ~= "" then error("Invalid Name!", 2) end
	
	stageplay.registered_actortypes[name] = def
end


function stageplay.register_actiontype(name, def)
	local invalidchars = name:gsub("[a-zA-Z0-9_:]", "")
	if type(name) ~= "string" then error("expected string, got "..type(name)) end
	if type(def) ~= "table" then error("expected table, got "..type(def)) end
	if invalidchars ~= "" then error("invalid name!", 2) end
	
	stageplay.registered_actiontypes[name] = def
end

function stageplay.register_scene(name, def)
	local invalidchars = name:gsub("[a-zA-Z0-9_:]", "")
	if type(name) ~= "string" then error("expected string, got "..type(name)) end
	if type(def) ~= "table" then error("expected table, got "..type(def)) end
	if invalidchars ~= "" then error("invalid name!", 2) end
	
	def.title = def.title or name
	
	stageplay.registered_scenes[name] = def
	
	minetest.register_node(name, {
		description = S("Spawn Scene \"@1\"", def.title),
		on_construct = function(pos)
			minetest.set_node(pos, {name="air"})
			stageplay.spawn_scene(name, pos)
		end
	})
end

function stageplay.add_actor(pos, stage, staticdata)
	if not type(staticdata) == "table" then staticdata = {} end
	
	staticdata.stage = stage
	staticdata.is_visible = staticdata.is_visible or false
	
	return minetest.add_entity(pos, "stageplay:actor", minetest.serialize(staticdata))
end

function stageplay.check_actor(self)
	if not self.type or not stageplay.registered_actortypes[self.type] then return false end
	local def = stageplay.registered_actortypes[self.type]
	if not def.check or not def.checkfunc(self.object) then
		return true
	end
end

-- STAGE FUNCTIONS --
local stages = {}

function stageplay.add_stage(name)
	stages[name] = {}
end


function stageplay.delete_stage(name)
	stages[name] = nil
end

function stageplay.stage_exists(name)
	return name and stages[name] ~= nil
end

local function bind(fn, args)
	return function()
		fn(table.unpack(args))
	end
end

-- SPAWN SCENE --
function stageplay.spawn_scene(name, pos)
	if not name or not stageplay.registered_scenes[name] then return end
	local def = stageplay.registered_scenes[name]
	local cast = def.cast
	local acts = def.actions
	local stage = vector.to_string(pos)
	local actors = {}

	-- make a stage
	stageplay.add_stage(stage)

	-- load cast
	for name,data in pairs(cast) do
		local pos2 = data.pos and vector.add(data.pos, pos) or pos
		data.name = name
		actors[name] = stageplay.add_actor(pos2, stage, data):get_luaentity()
	end

	-- load actions
	for k,v in pairs(acts) do
		local timing = tonumber(k) * 0.001
		for actor,actions in pairs(v) do
			for _,act in ipairs(actions) do
				local params = table.clone(act)
				local at = params[1]
				local atdef = stageplay.registered_actiontypes[at]
				if not type(at) == "string" then 
					error("expected string for actiontype name, got type "..type(at).." instead", 2)
				end
				if not atdef then
					error("unknown actiontype: \""..at.."\"", 2)
				end
				params[1] = actors[actor] or {stage=stage, pos=pos}
				if atdef.check then atdef.check(params) end
				minetest.after(timing, bind(atdef.func, params))
			end
		end
	end
	return true
end

dofile(path.."/actor.lua")
dofile(path.."/default.lua")

print("[MOD] Stageplay API Loaded")
