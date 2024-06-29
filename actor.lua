stageplay.registered_actortypes = {}

function stageplay.register_actortype(name, def)
	local invalidchars = name:gsub("[a-zA-Z0-9_:]", "")
	
	if invalidchars ~= "" then error("Invalid Name!", 2) end
	
	stageplay.registered_actortypes[name] = def
end

function stageplay.check_actor(self)
	if not self.type or not stageplay.registered_actortypes[self.type] then return false end
	local def = stageplay.registered_actortypes[self.type]
	if not def.check or def.check(self.object) then
		return true
	end
end

function stageplay.actfunc(self, staticdata, dtime_s)
	
	if staticdata then
		local sdat = minetest.deserialize(staticdata)
		if not sdat then self.object:remove() return end
		for k,v in pairs(sdat) do
			self[k] = v
		end
		self.object:set_properties({
			visual = self.visual,
			mesh = self.mesh,
			textures = self.textures,
			colors = self.colors,
			visual_size = self.visual_size,
		})
	end
	
end
function stageplay.stepfunc(self, dtime, moveresult)
	
	if not stageplay.stage_exists(self.stage) or not stageplay.check_actor(self) then
		self.object:remove()
	end
	
end
function stageplay.statfunc(self)
	return minetest.serialize({
		stage = self.stage,
		name = self.name
	})
end

minetest.register_entity("stageplay:actor", {
    on_step = stageplay.stepfunc,
	on_activate = stageplay.actfunc,
    get_staticdate = stageplay.statfunc,
})