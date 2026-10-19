Log("Metal Slug Lua script started")

local MetalSlug = {}

local vehicleID = 5
local timesRevived = 0


function MetalSlug:OnReset()
	timesRevived = 0
end

function MetalSlug:OnGameFinalised()
end

function MetalSlug:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function MetalSlug:OnPlayerRevivedBegin()
	timesRevived = timesRevived + 1
	if(timesRevived > 1) then
		return
	end
end

function Respawn()
	Log("Pirate Lua: Player revived")
	vehicleID = math.floor(EventSystem.GetFloatOverride("revive_vehicle", -1.0))
	if vehicleID >= 0 then
		GiveVehicle(vehicleID)
	end
end

function MetalSlug:OnPlayerRevivedFinish(reviveType)
	local samReviveType = 6 -- see ReviveType::Type enum for values.
	if reviveType ~= samReviveType then
		Respawn()
	end
end

RegisterGameRules("MetalSlug", "GameRules", MetalSlug);
