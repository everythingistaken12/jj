return function(count, vehicle_required, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		accumulated_distance = common.get_progress(current_mission),
		id = current_mission,
		vehicle_required = vehicle_required,
		count = count,
		toast_icon = toast_icon,
		toast_message = toast_message,
		is_in_vehicle = false,
		started_vehicle_at = 0,
		last_distance = 0
	}

	common.set_max_progress(mission.id, mission.count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.accumulated_distance)..'/'..tostring(mission.count))

	function mission:on_game_ended(event_name, abruptly, total_distance)
		self.is_in_vehicle = false
		self.last_distance = 0

		if self.vehicle_required then
			self.accumulated_distance = common.get_progress(self.id)
		end

		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring game end.')
			return
		end
		
		if abruptly == true then
			print('Mission '..self.id..' : Game ended abruptly. Doesnt count.')
			return
		end

		if not self.vehicle_required then
			self.accumulated_distance = self.accumulated_distance + total_distance
			common.set_progress(self.id, self.accumulated_distance)
		end
	end

	function mission:on_reached_distance_alive(distance, in_vehicle)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring progress update.')
			return
		end

		if self.is_in_vehicle and not in_vehicle then
			self.is_in_vehicle = false

			if self.vehicle_required then
				self.accumulated_distance = common.get_progress(self.id)
			end
		end

		if not self.is_in_vehicle and in_vehicle then
			self.is_in_vehicle = true
			self.started_vehicle_at = self.last_distance
		end

		self.last_distance = distance

		local total_progress = self.accumulated_distance

		if self.vehicle_required and in_vehicle then
			total_progress = total_progress + (distance - self.started_vehicle_at)
			common.set_progress(self.id, total_progress)
		elseif not self.vehicle_required then
			total_progress = total_progress + distance
		end

		if total_progress >= self.count then
			common.set_progress(self.id, self.count)
			common.set_completed(self.id)
			self.done_ = 1
			show_toast(self.toast_icon, self.toast_message)
		end
	end

	return mission
end
