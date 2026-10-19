Log("Particle Script Loaded v1.0.01")

---
-- Enum: Particle LocalToWorld Type
---
ParticleLTWType =
{
	LevelRelative = 1,
	ScreenRelative = 2,
	Fullscreen = 3,
}

---
-- Particle class
---
Particle = {}

function Particle.new(systemName, startPos, ltwType, isLooping)
	local newParticle = {}
	newParticle.emitter = nil
	newParticle.systemName = systemName
	newParticle.pos = Vector.Clone(startPos)
	newParticle.startPos = Vector.Clone(startPos)
	newParticle.targetPos = Vector.Clone(startPos)
	newParticle.worldPos = Vector.New(0, 0)
	newParticle.isActive = false
	newParticle.isActiveDirty = true
	newParticle.isLoaded = false
	newParticle.ltwType = ltwType
	newParticle.updateCount = 0
	newParticle.isLooping = isLooping

	---
	-- Update(owner)
	--  Takes the owner Vehicle as a parameter.
	--  If visible, rotates its position about the owner's origin.
	---
	function newParticle:Update(owner)
		if (self.isActive and self.isLoaded == false) then
			self:Load()
			self.isActiveDirty = false
		end

		if (self.isActiveDirty) then
			-- Reset update count, either way
			self.updateCount = 0

			-- Update emitter active state
			if (self:IsEmitterValid()) then
				SetParticleEnabled(self.emitter, self.isActive)
			end

			-- Destroy Emitter if no longer needed
			if (self.isActive == false) then
				self:DestroyEmitter()
			end

			-- Clear dirty
			self.isActiveDirty = false
		end

		if (self.isActive) then
			-- Update update count
			self.updateCount = self.updateCount + 1

			-- If we are a looping emitter, ensure we are still valid
			-- If we are a one-shot emitter, ensure we are valid for at least one frame
			if (self.isLooping or self.updateCount == 1) then
				self:EnsureEmitterValid()
			end

			if (self:IsEmitterValid()) then
				local rotation = owner.rotation
				self:UpdateWorldPos(rotation)

				SetParticlePosition(self.emitter, self.worldPos[1], self.worldPos[2])
			end
		end

	end

	---
	-- UpdateWorldPos(rotation)
	--  Updates self.worldPos, using the Level offset, and player position.
	--  If isFullscreen, only the Level offset is used, and no rotation.
	---
	function newParticle:UpdateWorldPos(rotation)
		if (self.ltwType == ParticleLTWType.LevelRelative) then
			local worldPos = Vector.New(Level.GetOffset())
			local playerPos = Vector.New(GetPlayerPosition())
			local rotatedPos = VectorMath.RotateVector(self.pos, rotation)
			self.worldPos = playerPos + rotatedPos - worldPos
		elseif (self.ltwType == ParticleLTWType.ScreenRelative) then
			local playerPos = Vector.New(GetPlayerPosition())
			local rotatedPos = VectorMath.RotateVector(self.pos, rotation)
			self.worldPos = playerPos + rotatedPos
		elseif (self.ltwType == ParticleLTWType.Fullscreen) then
			local worldPos = Vector.New(Level.GetOffset())
			self.worldPos = Vector.New(360, 0) - worldPos
		end
	end

	---
	-- SetActive(isActive)
	---
	function newParticle:SetActive(active)
		if (self.isActive ~= active) then
			self.isActive = active
			self.isActiveDirty = true
		end
	end

	---
	-- Loads the particle, if not already.
	---
	function newParticle:Load()
		if (self.isLoaded == false) then
			Debug.Log(Debug.Particles, "Particle:Load> Creating emitter " .. self.systemName)

			-- Destroy old emitter
			self:DestroyEmitter()

			-- Create new emitter
			self.emitter = CreateParticle(self.systemName)
			self.isLoaded = true
		end
	end

	---
	-- Destroys the emitter, if it exists
	---
	function newParticle:DestroyEmitter()
		if (self.emitter ~= nil) then

			-- Log to console
			Debug.Log(Debug.Particles, "Particle:DestroyEmitter> Destroying emitter " .. self.systemName .. " (" .. tostring(self.emitter) .. ")")

			-- Destroy old emitter
			DestroyParticle(self.emitter)
			self.emitter = nil
			self.isLoaded = false
		end
	end

	---
	-- Returns TRUE if the current emitter handle is valid
	---
	function newParticle:IsEmitterValid()
		local isValid = self.emitter ~= nil and IsParticleValid(self.emitter)
		return isValid
	end

	---
	-- Ensures that the emitter handle is valid, if not, tries to re-create it
	---
	function newParticle:EnsureEmitterValid()
		if (self.isActive and self:IsEmitterValid() == false) then
			if (self.isLoaded) then
				Debug.Log(Debug.Particles, "Particle:EnsureEmitterValid> Emitter not valid, recreating: " .. self.systemName .. " (" .. tostring(self.emitter) .. ")")
				self.isLoaded = false
			end

			self:Load()
		end
	end

	return newParticle
end
