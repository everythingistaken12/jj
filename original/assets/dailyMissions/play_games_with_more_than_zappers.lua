local actor_names = require("actor_names")
return function(games_count, actor_count, actor, allow_revive, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		value = common.get_progress(current_mission),
		id = current_mission,
		games_count = games_count,
		actor_count = actor_count,
		actor = actor,
		toast_icon = toast_icon,
		toast_message = toast_message,
		zapper_count = 0,
		allow_revive = allow_revive,
		current_round_success = false
	}

	common.set_max_progress(mission.id, mission.games_count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.value)..'/'..tostring(mission.games_count))

	function mission:on_actor_cleared(actor_type)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring game end.')
			return
		end

		if actor_type == self.actor then
			self.zapper_count = self.zapper_count + 1

			if self.zapper_count >= self.actor_count and not self.current_round_success then
				self.value = self.value + 1
				self.current_round_success = true

				common.set_progress(self.id, self.value)
				print('Mission '..self.id..' progressed: '..tostring(self.value)..'/'..tostring(self.games_count))

				if self.value >= self.games_count then
					common.set_completed(self.id)
					self.done_ = 1
					show_toast(self.toast_icon, self.toast_message)
				end
			end

		end

		
	end

	function mission:on_game_ended(event_name, abruptly, total_distance)
		if self.done_ > 0 or abruptly then
			self.zapper_count = 0
			self.current_round_success = false
			print('Mission '..current_mission..' is already completed. Ignoring game end.')
			return
		end

		self.zapper_count = 0
		self.current_round_success = false
	end

	function mission:on_player_revived(type)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring revive.')
			return
		end	

		if not allow_revive then
			self.zapper_count = 0
		end

	end

	return mission
end