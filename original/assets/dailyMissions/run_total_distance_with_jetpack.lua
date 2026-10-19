return function(count, jetpack, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		accumulated_distance = common.get_progress(current_mission),
		id = current_mission,
		jetpack = jetpack,
		count = count,
		toast_icon = toast_icon,
		toast_message = toast_message,
		last_distance = 0
	}

	common.set_max_progress(mission.id, mission.count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.accumulated_distance)..'/'..tostring(mission.count))

	function mission:on_game_ended(event_name, abruptly, total_distance)
		self.last_distance = 0

		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring game end.')
			return
		end
		
		if abruptly == true then
			print('Mission '..self.id..' : Game ended abruptly. Doesnt count.')
			return
		end

		if self.jetpack == get_equipped_jetpack() then
			self.accumulated_distance = self.accumulated_distance + total_distance
				common.set_progress(self.id, self.accumulated_distance)
		end

	end

	function mission:on_reached_distance_alive(distance, in_vehicle)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring progress update.')
			return
		end

		self.last_distance = distance

		local total_progress = self.accumulated_distance
		if self.jetpack == get_equipped_jetpack() then
			total_progress = total_progress + distance
		end		

		if self.jetpack == get_equipped_jetpack() then
			if total_progress >= self.count then
				common.set_progress(self.id, self.count)
				common.set_completed(self.id)
				self.done_ = 1
				show_toast(self.toast_icon, self.toast_message)
			end
		end
	end

	return mission
end
