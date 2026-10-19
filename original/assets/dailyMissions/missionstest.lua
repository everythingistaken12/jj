local mission = {}

mission.played_games = 0
mission.total_distance = 0

function mission:on_game_ended(event_name, abruptly, total_distance)
	print("on_game_ended called with: " .. tostring(event_name) .. ", " .. tostring(abruptly) .. ", " .. tostring(total_distance))
    self.played_games = self.played_games + 1
end


function mission:on_reached_distance_alive(distance)
	distance = tonumber(distance) or 0 -- Ensure it's a number
    print("distance updated = "..tostring(distance))
end

return mission
