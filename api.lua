stageplay.registered_actiontypes = {}
stageplay.registered_scenes = {}

local S = stageplay.get_translator

local stages = {}

function stageplay.add_actor(pos, stage, staticdata)
	if not type(staticdata) == "table" then staticdata = {} end
	
	staticdata.stage = stage
	
	return minetest.add_entity(pos, "stageplay:actor", minetest.serialize(staticdata))
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

local function bind(fn, args)
	return function()
		fn(table.unpack(args))
	end
end

function stageplay.add_stage(name)
	stages[name] = {}
end


function stageplay.delete_stage(name)
	stages[name] = nil
end

function stageplay.stage_exists(name)
	return name and stages[name] ~= nil
end

function stageplay.spawn_scene(name, pos)
	if not name or not stageplay.registered_scenes[name] then return end
	local def = stageplay.registered_scenes[name]
	local cast = def.data.cast
	local acts = def.data.actions
	local stage = vector.to_string(pos)
	local actors = {}
	
	stageplay.add_stage(stage)
	
	for name,data in pairs(cast) do
		local pos2 = data.pos and vector.add(data.pos, pos) or pos
		data.name = name
		actors[name] = stageplay.add_actor(pos2, stage, data).object
	end
	
	for k,v in pairs(acts) do
		local timing = tonumber(k) * 0.001
		if v == "end" then
			minetest.after(timing, bind(stageplay.delete_stage, {stage}))
		else
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
					params[1] = actors[actor]
					if atdef.check then atdef.check(params) end
					minetest.after(timing, bind(atdef.func, params))
				end
			end
		end
	end
	return true
end