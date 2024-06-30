stageplay.register_actortype("stageplay:default_actor", {
	checkfunc = function()
		-- code returns true if actor should be deleted
	end
})

stageplay.register_actiontype("stageplay:move_by", {
	func = function(self, tpos, timing)
		if not self then return end		-- do not do operations on nil
		
		local s = stageplay.ms2s(timing)	-- convert miliseconds to seconds
		
		local endpos = vector.add(self.object:get_pos(), tpos)
		
		self.object:set_velocity(
			vector.divide(tpos, s)
		)
		minetest.after(s, function()
			self.object:set_velocity(vector.zero())
			self.object:set_pos(endpos)
		end)
	end
})

stageplay.register_actiontype("stageplay:show", {
	func = function(self)
		if not self then return end		-- do not do operations on nil
		self.object:set_properties(
			is_visible = true
		)
	end
})

stageplay.register_actiontype("stageplay:hide", {
	func = function(self)
		if not self then return end		-- do not do operations on nil
		self.object:set_properties(
			is_visible = false
		)
	end
})

stageplay.register_actiontype("stageplay:animate", {
	func = function(self, anim)
		if not self then return end		-- do not do operations on nil
										-- do not animate if no animations
		if not self.animations or not self.animations[anim] then 
			return 
		end
		
		
		local aparms = {}				-- taken from mobkit/init.lua
		if #self.animations[anim] > 0 then
			aparms = self.animations[anim][random(#self.animations[anim])]
		else
			aparms = self.animations[anim]
		end
		
		aparms.frame_blend = aparms.frame_blend or 0
		
		self.object:set_animation(aparms.range, aparms.speed, aparms.frame_blend, aparms.loop)
	end
})

stageplay.register_actiontype("stageplay:update_visual", {
	func = function(self, visual)
		if not self then return end		-- do not do operations on nil
		
		self.object:set_properties({	-- set visual data
			visual = visual.visual,
			mesh = visual.mesh,
			textures = visual.textures,
			colors = visual.colors,
			visual_size = visual.visual_size,
		})
	end
})
