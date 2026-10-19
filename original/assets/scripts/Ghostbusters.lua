Log("Ghostbusters Lua script started")

local Ghostbusters = {}

local vehicleID = 5
local timesRevived = 0


function Ghostbusters:OnReset()
	timesRevived = 0
end

function Ghostbusters:OnGameFinalised()
	
end

function Ghostbusters:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function Ghostbusters:OnPlayerRevivedBegin()
	timesRevived = timesRevived + 1
	if(timesRevived > 1) then
		return
	end

	SetCostumeHead("GB_MOOGLIE_HEAD")
	SetCostumeBody("GB_MOOGLIE_BODY")

end

function Ghostbusters:OnPlayerRevivedFinish(reviveType)
	local samReviveType = 6 -- see ReviveType::Type enum for values.
	if reviveType ~= samReviveType then
		Respawn()
	end
end

function Respawn()
	Log("Ghostbusters Lua: Player revived")

	-- give vehicle 
	--SetVehicleSkin("GhostTrain",vehicleID)
	GiveVehicle(vehicleID)

end

RegisterGameRules("Ghostbusters", "GameRules", Ghostbusters);
