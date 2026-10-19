Log("CutAndRun Lua script started")

local CutAndRun = {}

function CutAndRun:OnGameFinalised()
	SFX.SetSongVolume(1.0)
end

RegisterGameRules("CutAndRun", "GameRules", CutAndRun);
