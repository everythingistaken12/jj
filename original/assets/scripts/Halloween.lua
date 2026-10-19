Log("Halloween Lua script started")

local Halloween = {}

local vehicleID = 5
local timesRevived = 0


function Halloween:OnReset()
	timesRevived = 0
end

function Halloween:OnGameFinalised()
	
end

function Halloween:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function Halloween:OnPlayerRevivedBegin()
	timesRevived = timesRevived + 1
	if(timesRevived > 1) then
		return
	end
	
	-- give costume
	-- SetCostumeJetpack("JETPACK_PUMPKIN")
	-- SetCostumeHead("DEATH_HEAD")
	-- SetCostumeBody("DEATH_BODY")
	
	SFX.StopSong()
end

function Halloween:OnPlayerRevivedFinish(reviveType)
	local samReviveType = 6 -- see ReviveType::Type enum for values.
	if reviveType ~= samReviveType then
		SpawnUndead()
	end
end

function SpawnUndead()
	Log("Halloween Lua: Player revived")

	-- give vehicle 
	--SetVehicleSkin("BoneDragon",vehicleID)
	GiveVehicle(vehicleID)

end

RegisterGameRules("Halloween", "GameRules", Halloween);
