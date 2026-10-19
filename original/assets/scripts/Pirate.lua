Log("Pirate Lua script started")

local Pirate = {}

local vehicleID = 5
local timesRevived = 0

function Pirate:OnReset()
	timesRevived = 0
end

function Pirate:OnGameFinalised()
end

function Pirate:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function Pirate:OnPlayerRevivedBegin()
	timesRevived = timesRevived + 1
	if(timesRevived > 1) then
		return
	end
end

function Pirate:OnPlayerRevivedFinish(reviveType)
	local samReviveType = 6 -- see ReviveType::Type enum for values.
	if reviveType ~= samReviveType then
		Respawn()
	end
end

function Respawn()
	Log("Pirate Lua: Player revived")
end

RegisterGameRules("Pirate", "GameRules", Pirate);
