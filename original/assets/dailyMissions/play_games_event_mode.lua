return function(count, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		value = common.get_progress(current_mission),
		id = current_mission,
		count = count,
		toast_icon = toast_icon,
		toast_message = toast_message
	}

	common.set_max_progress(mission.id, mission.count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.value)..'/'..tostring(mission.count))

	function mission:on_game_ended(event_name, abruptly, total_distance)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring game end.')
			return
		end

		if abruptly == true then
			print('Mission '..self.id..' : Game ended abruptly. Doesnt count.')
			return
		end

		if event_name == "" then
			print('Mission '..self.id..': completed game was not in event')
			return
		end

		self.value = self.value + 1
		common.set_progress(self.id, self.value)
		print('Mission '..self.id..' progressed: '..tostring(self.value)..'/'..tostring(self.count))

		if self.value >= self.count then
			common.set_completed(self.id)
			self.done_ = 1
			show_toast(self.toast_icon, self.toast_message)
		end
	end

	return mission
end