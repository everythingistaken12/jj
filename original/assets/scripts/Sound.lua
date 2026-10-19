Log("Sound Lua script started v1.0.02")

---
-- Sound class
---
Sound = {}
function Sound.new(soundName, isTrack, volume, speedEvent)
	local newSound = {}
	newSound.handle = nil
	newSound.isActive = false
	newSound.soundName = soundName
	newSound.isTrack = isTrack or false
	newSound.volume = volume or 1.0
	newSound.speedEvent = speedEvent
	newSound.pitch = 1.0

	function newSound:Play()
		if (self.isActive == false) then
			self.handle = SFX.PlaySound(self.soundName, self.isTrack, self.volume)
			Debug.Log(Debug.Sounds, "SFX.PlaySound: " .. self.soundName .. " isTrack: " .. tostring(self.isTrack) .. " volume: " .. tostring(self.volume) .. " handle: ".. tostring(self.handle))
			if (self.handle == -1) then
				self.handle = nil
			else
				self.isActive = true
			end
		end
	end

	function newSound:SetPitch(pitch)
		if (self.isActive and self.handle ~= nil) then
			if (self.pitch ~= pitch) then
				Debug.Log(Debug.Sounds, "SFX.SetPitch: old: " .. tostring(self.pitch) .. " new: " .. tostring(pitch))
				self.pitch = pitch
				SFX.SetSoundPitch(self.handle, self.pitch)
			end
		else
			Debug.Log(Debug.Sounds, "SFX.SetPitch: active: " .. tostring(self.isActive) .. " handle: " .. tostring(self.handle))
		end
	end

	function newSound:Stop(fadeOut)
		if (self.isActive and self.handle ~= nil) then
			Debug.Log(Debug.Sounds, "SFX.StopSound: " .. self.soundName)
			self.isActive = false
			SFX.StopSound(self.handle or -1, fadeOut)
		end
	end

	function newSound:CheckSpeedEvent(previousValue, currentValue)
		if (self.speedEvent ~= nil) then
			if (self.speedEvent:Check(previousValue, currentValue)) then
				self:Play()
			end
		end
	end

	function newSound:SetVolume(volume)
		if(self.volume ~= volume) then
			SFX.SetSoundVolume(self.handle or -1, volume)
			self.volume = volume
		end
	end

	return newSound
end
