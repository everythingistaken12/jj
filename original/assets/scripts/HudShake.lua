Log("HudShake Lua script started v1.0.01")

---
-- HudShake class
--
---
HudShake = {}
function HudShake.New(shakeName, shakeTime, shakeIntensity, shakeSpeed)
	local newHudShake = {}
	newHudShake.shakeName = shakeName
	newHudShake.shakeTime = shakeTime
	newHudShake.shakeIntensity = shakeIntensity
	newHudShake.shakeSpeed = shakeSpeed

	---
	-- HudShake:Shake()
	--  Shakes the level now
	---
	function newHudShake:Shake()
		Debug.Log(Debug.HudShakes, "HudShake:Shake " .. self.shakeName)
		Level.ScreenShake(self.shakeTime, self.shakeIntensity, self.shakeSpeed)
	end

	return newHudShake
end
