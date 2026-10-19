local mission = {
	done_ = common.is_completed(current_mission),
	id = current_mission
}

common.set_max_progress(mission.id, 1)

function mission:update(dt)
	if self.done_ > 0 then
		return
	end

	self.done_ = 1
	common.set_completed(self.id)
	common.set_progress(self.id, 1)
	
	show_toast('textures/menus/missions/iconStar.tex', 'Freebie')
end


function mission:current_progress()
	return 1
end

function mission:max_progress()
	return 1
end

return mission