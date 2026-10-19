return function(games_count, actor_count, actor_type, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		value = common.get_progress(current_mission),
		id = current_mission,
		games_count = games_count,
		actor_count = actor_count,
		actor_type = actor_type,
		distance_count = distance_count,
		toast_icon = toast_icon,
		toast_message = toast_message,
		actor_collected = 0
	}

	common.set_max_progress(mission.id, mission.games_count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.value)..'/'..tostring(mission.games_count))

	function mission:on_game_ended(event_name, abruptly, total_distance)
		if self.done_ > 0 or abruptly then
			self.actor_collected = 0
			print('Mission '..current_mission..' is already completed. Ignoring game end.')
			return
		end

		if self.actor_collected > self.actor_count then
			self.value = self.value + 1
			common.set_progress(self.id, self.value)

			print('Mission '..current_mission..' progressed: '..tostring(self.value)..'/'..tostring(self.games_count))

			if self.value >= self.games_count then
				common.set_completed(self.id)
				self.done_ = 1
				show_toast(self.toast_icon, self.toast_message)
			end
		end

		self.actor_collected = 0
	end

	function mission:on_actor_collected(actor_type, count)
		if self.done_ > 0 then
			print('Mission on actor collected'..self.id..' is already completed. Ignoring coin collected')
			return
		end

		count = count or 1

		if self.actor_type == actor_type then
			self.actor_collected = self.actor_collected + count
		end
	end

	return mission
end