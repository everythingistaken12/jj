return function(count, vehicle_skin, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		value = common.get_progress(current_mission),
		id = current_mission,
		vehicle_skin = vehicle_skin,
		count = count,
		toast_icon = toast_icon,
		toast_message = toast_message,
		is_in_vehicle = false;
	}

	common.set_max_progress(mission.id, mission.count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.value)..'/'..tostring(mission.count))

	function mission:on_game_ended(event_name, abruptly, total_distance)
		self.is_in_vehicle = false

		if self.done_ > 0 or abruptly then
			print('Mission '..self.id..' is already completed. Ignoring game end.')
			return
		end

		if self.value >= self.count then
			common.set_completed(self.id)
			self.done_ = 1
			show_toast(self.toast_icon, self.toast_message)
		end
	end

	function mission:on_reached_distance_alive(distance, in_vehicle)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring progress update.')
			return
		end

		if self.is_in_vehicle and not in_vehicle then
			self.is_in_vehicle = false
		end

		if not self.is_in_vehicle and in_vehicle then
			self.is_in_vehicle = true			

			if self.vehicle_skin == get_equipped_vehicle_skin() then
				self.value = self.value + 1
				common.set_progress(self.id, self.value)
				print('Mission '..self.id..' progressed: '..tostring(self.value)..'/'..tostring(self.count))
			end

			if get_equipped_vehicle_skin() == "" then
				
				if self.vehicle_skin == get_equipped_vehicle_type() then
					self.value = self.value + 1
					common.set_progress(self.id, self.value)
					print('Mission '..self.id..' progressed: '..tostring(self.value)..'/'..tostring(self.count))
				end
			end

		end

		if self.value >= self.count then
			common.set_progress(self.id, self.count)
			common.set_completed(self.id)
			self.done_ = 1
			show_toast(self.toast_icon, self.toast_message)
		end
	end

	return mission
end