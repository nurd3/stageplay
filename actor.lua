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
	
	if not stageplay.stage_exists(self.stage) or stageplay.check_actor(self) then
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
	get_staticdata = stageplay.statfunc,
})
