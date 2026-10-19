Log("StPatricks Lua script started")

local StPatricks = {}

local vehicleID = 1
local timesRevived = 0


function StPatricks:OnReset()
	timesRevived = 0
end

function StPatricks:OnGameFinalised()
	
end

function StPatricks:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function StPatricks:OnPlayerRevivedBegin()
	timesRevived = timesRevived + 1
	if(timesRevived > 1) then
		return
	end
	
	SFX.StopSong()
end

function StPatricks:OnPlayerRevivedFinish(reviveType)
	local samReviveType = 6 -- see ReviveType::Type enum for values.
	if reviveType ~= samReviveType then
		Respawn()
	end
end

function Respawn()
	Log("StPatricks Lua: Player revived")

	-- give vehicle 
	--SetVehicleSkin("BoneDragon",vehicleID)
	GiveVehicle(vehicleID)

end

RegisterGameRules("StPatricks", "GameRules", StPatricks);
