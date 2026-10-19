local actor_names = require("actor_names") -- a test of require

if mission_id == nil then
	mission_id = 0
end

mission_id = mission_id + 1

local mission = {
	id = mission_id
}

print('Mission'..tostring(mission.id)..' has been created')

function mission:on_game_ended(event_name, abruptly, total_distance)
    print('mission:on_game_ended: ' .. tostring(event_name) .. ' ' .. tostring(abruptly) .. ' ' .. tostring(total_distance))
end


function mission:on_reached_distance_alive(distance, in_vehicle)
	print("mission:on_reached_distance_alive: "..tostring(distance) .. ' ' ..tostring(in_vehicle))
end

function mission:on_actor_collected(actor_type, count)
	count = count or 1
	print('mission:on_actor_collected: '..actor_type..', count = '..count)
end

function mission:on_player_revived(type)
	print('mission:on_player_revived: '..type)
end

function mission:on_destroy()
	print('mission'..tostring(self.id)..':on_destroy')
end

return mission