Log("TMNT Lua script started")

local TMNT = {}

local vehicleID = 5
local timesRevived = 0


function TMNT:OnReset()
	timesRevived = 0
end

function TMNT:OnGameFinalised()
	
end

function TMNT:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function TMNT:OnPlayerRevivedBegin()
	timesRevived = timesRevived + 1
	if(timesRevived > 1) then
		return
	end


end

function TMNT:OnPlayerRevivedFinish(reviveType)
	if reviveType ~= samReviveType then
		Respawn()
	end
end

function Respawn()
	Log("TMNT Lua: Player revived")

	-- give vehicle 
	--SetVehicleSkin("GhostTrain",vehicleID)
	GiveVehicle(vehicleID)

end

RegisterGameRules("TMNT", "GameRules", TMNT);
