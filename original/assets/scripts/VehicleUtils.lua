Log("VehicleUtils Lua Script Loaded")

VehicleUtils = {}

function VehicleUtils.GetFallingSoundVolume(max_speed)
	local velocity = Vector.New(GetVehicleVelocity())
	local y = velocity[2]

	local fraction = (math.abs(y) / max_speed)
	local vol = fraction * fraction * fraction
	if(vol> 1) then
		return 1
	else
		return vol
	end
end

function VehicleUtils.GetFallingVelocity()
	local velocity = Vector.New(GetVehicleVelocity())
	local y = velocity[2]
	return y
end


function VehicleUtils.PlaySong(vehicle, track, location)
    local name, delay, fadein, set_level_song = vehicle.Base.GetMusicTrack(vehicle, track, location)
    if (name ~= nil and name ~= '') then
        SFX.PlaySong(name, delay, fadein, set_level_song)
        return true
    end

    return false
end

function VehicleUtils.PlayOutro(vehicle)

	local name, delay, fadein, set_level_song, success = vehicle.Base.GetMusicTrack(vehicle, "stop_music", "vehicle_destroy")
	if (success) then
		SFX.StopSong(delay)
	end

    VehicleUtils.PlaySong(vehicle, "outro", "")
    if (VehicleUtils.PlaySong(vehicle, "continue_with", "")) then
        return true
    end

    return false
end

function VehicleUtils.Copy(vehicle)
    local orig_type = type(vehicle)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(vehicle) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = vehicle
    end
    return copy
end

function VehicleUtils.PlayRandomSFX(sfx)
    local sound = math.random(#sfx)
	sfx[sound]:Play()
end

function VehicleUtils.StopAllSFX(sfx)
	for i = 1, #sfx, 1 do
		sfx[i]:Stop(0.05)
    end
end