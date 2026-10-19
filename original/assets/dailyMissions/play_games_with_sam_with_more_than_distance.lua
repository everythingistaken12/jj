return function(games_count, distance_count, toast_icon, toast_message)
	local mission = {
		done_ = common.is_completed(current_mission),
		value = common.get_progress(current_mission),
		id = current_mission,
		games_count = games_count,
		distance_count = distance_count,
		start_distance = 0,
		toast_icon = toast_icon,
		toast_message = toast_message,
		is_in_sam = false,
		require_new_sam = false
	}

	common.set_max_progress(mission.id, mission.games_count)
	common.set_mission_description(mission.id, mission.toast_message)

	print('Creating mission '..current_mission..', progress: '
		..tostring(mission.value)..'/'..tostring(mission.games_count))

	function mission:on_reached_distance_alive(distance, in_vehicle)
		if self.done_ > 0 then
			print('Mission '..self.id..' is already completed. Ignoring progress update.')
			return
		end

		if self.is_in_sam and not (get_equipped_vehicle_type() == "sam") then
			self.is_in_sam = false
		end

		if not self.is_in_sam and get_equipped_vehicle_type() == "sam" then
			self.is_in_sam = true
			self.start_distance = distance
			self.require_new_sam = false
			--self.value = self.value + 1
			--common.set_progress(self.id, self.value)
			--print('Mission '..self.id..' progressed: '..tostring(self.value)..'/'..tostring(self.count))
		end

		if self.is_in_sam and get_equipped_vehicle_type() == "sam" and not self.require_new_sam then
			if (distance - self.start_distance) > self.distance_count then
				self.value = self.value + 1
				self.require_new_sam = true
				common.set_progress(self.id, self.value)
				print('Mission '..self.id..' progressed: '..tostring(self.value)..'/'..tostring(self.games_count))

				if self.value >= self.games_count then
					common.set_completed(self.id)
					self.done_ = 1
					show_toast(self.toast_icon, self.toast_message)
				end
			end		
		end		

		--if self.value >= self.count then
			--common.set_progress(self.id, self.count)
			--common.set_completed(self.id)
			--self.done_ = 1
			--show_toast(self.toast_icon, self.toast_message)
		--end
	end

	return mission
end