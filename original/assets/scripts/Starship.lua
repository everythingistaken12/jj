Log("Starship Lua script started v1.2.36")

-- The Starship itself
Starship = Starship or {}

-- Starship members
Starship.rotation = 0.0
Starship.verticalSpeed = 0.0
Starship.savedSpeed = 0.0
Starship.burstStatus = 0.0
Starship.isBursting = false
Starship.isPressed = false
Starship.scale = Vector.New(0.6, 0.6)

-- visuals
Starship.isFiringBurst     = false
Starship.areJetsActive     = false
Starship.hasThrusterPlayed = false
Starship.activeStatusLeds  = 0

---
-- Starship Sounds
---
Starship.Sounds = {}

-- to play when the vehicle has finished forming
Starship.Sounds.FormComplete = Sound.new("st_shuttle_form_complete")

-- looping sounds
Starship.Sounds.Engine   = Sound.new("st_shuttle_engine_lp", true, 1.0)
Starship.Sounds.Burst   = Sound.new("st_shuttle_warp_tunnel_lp", true, 1.0)
Starship.Sounds.Jets     = Sound.new("jetpack_blast_lp", true, 1.0)

-- one time effects
Starship.Sounds.Status      = Sound.new("st_shuttle_warp_meter")
Starship.Sounds.StatusFull  = Sound.new("st_shuttle_warp_meter_full")
Starship.Sounds.Thruster    = Sound.new("st_shuttle_thruster")
Starship.Sounds.BurstStart  = Sound.new("st_shuttle_warp_enter")
Starship.Sounds.BurstFinish   = Sound.new("st_shuttle_warp_exit")

-- to play when it is destroyed
Starship.Sounds.Death = Sound.new("st_shuttle_death")

---
-- Starship sprites
---
Starship.Sprites = {}
Starship.Sprites.Main     = Sprite.New("textures/Characters/Vehicles/Starship/Starship/starship.xml", 11)
Starship.Sprites.Inner    = Sprite.New("textures/Characters/Vehicles/Starship/starship_inside.xml", 9)
Starship.Sprites.Glow    = Sprite.New("textures/Characters/Vehicles/Starship/Starship/glow.xml", 13)

Starship.Sprites.Burst       = Sprite.New("textures/Characters/Vehicles/Starship/Starship/starship_burst.xml", 12)
Starship.Sprites.JetBottomLeft       = Sprite.New("textures/Characters/Vehicles/Starship/Starship/starship_jet.xml", 12)
Starship.Sprites.JetBottomRight       = Sprite.New("textures/Characters/Vehicles/Starship/Starship/starship_jet.xml", 12)

-- UI stuff
Starship.Sprites.SpeedTable = Sprite.New("textures/Characters/Vehicles/Starship/Starship/speedtable.xml", 12)
Starship.Sprites.SpeedTableBurstLeft = Sprite.New("textures/Characters/Vehicles/Starship/Starship/speedtable_burst_left.xml", 12)
Starship.Sprites.SpeedTableBurstRight = Sprite.New("textures/Characters/Vehicles/Starship/Starship/speedtable_burst_right.xml", 12)
Starship.Sprites.SpeedTablePatchesLeft = {}
for i = 1, 7 do
	Starship.Sprites.SpeedTablePatchesLeft[i] = Sprite.New("textures/Characters/Vehicles/Starship/Starship/speedtable_patch.xml", 12)
end
Starship.Sprites.SpeedTablePatchesRight = {}
for i = 1, 7 do
	Starship.Sprites.SpeedTablePatchesRight[i] = Sprite.New("textures/Characters/Vehicles/Starship/Starship/speedtable_patch.xml", 12)
end

Starship.Sprites.Main.scale   = Vector.Clone(Starship.scale)
Starship.Sprites.Inner.scale  = Vector.Clone(Starship.scale)
Starship.Sprites.Glow.scale  = Vector.Clone(Starship.scale)
Starship.Sprites.Burst.scale = Vector.Clone(Starship.scale)
Starship.Sprites.JetBottomLeft.scale = Vector.Clone(Starship.scale)
Starship.Sprites.JetBottomRight.scale = Vector.Clone(Starship.scale)

---
-- Starship Particles
---
Starship.Particles = {}
Starship.Particles.Sparks = Particle.new("Starship_Sparks", Vector.New(0, 0), ParticleLTWType.ScreenRelative, true)
Starship.Particles.HoverDust = Particle.new("Starship_Hover", Vector.New(25, -23), ParticleLTWType.ScreenRelative, true)
Starship.Particles.Streaks = Particle.new("Starship_Streaks", Vector.New(25, 0), ParticleLTWType.ScreenRelative, true)

---
-- GetTextureList()
--  Called from cpp.
---
function Starship.GetTextureList()
	return
		"textures/Characters/Vehicles/starship/starship/starship_bg.tex" ..
		"|textures/Characters/Vehicles/starship/starship/glow.tex" ..
		"|textures/Characters/Vehicles/starship/starship/starship_burst.tex" ..
		"|textures/Characters/Vehicles/starship/starship/starship_burst.tex" ..
		"|textures/Characters/Vehicles/starship/starship/starship_jet.tex" ..
		"|textures/Characters/Vehicles/starship/starship/speedtable2.tex" ..
		"|textures/Characters/Vehicles/starship/starship/speedtable_burst_left.tex" ..
		"|textures/Characters/Vehicles/starship/starship/speedtable_burst_right.tex" ..
		"|textures/Characters/Vehicles/starship/starship/speedtable_patch.tex"
end

---
-- PickupStart()
--  ???
---
function Starship:PickupStart()
	Debug.Log(Debug.General, "Starship:PickupStart")
	-- OffsetPickupComponents(2,18)
	SetFirstComponentToFront(true)
end

---
-- ConstructionComplete()
--  Called from cpp, when the Starship has finished being constructed.
---
function Starship:ConstructionComplete()
	Debug.Log(Debug.General, "Starship:ConstructionComplete")
	self.Sounds.FormComplete:Play()
	self.Sounds.Engine:Play()
end

---
-- OnInit
--  Called from cpp when the Vehicle has just been Initialized.
--
-- Note: The Vehicle may be drawn before its first update.
--       So, make sure that its state is presentable.
---
function Starship:OnInit(info)
	Debug.Log(Debug.General, "Starship:OnInit")
	self.Base.OnInit(self, info)

	-- Load Main body
	self.Sprites.Main:Load()
	self.Sprites.Main:PlayAnimation("idle")
	self.Sprites.Inner:Load()
	self.Sprites.Glow:Load()
	self.Sprites.Glow:PlayAnimation("idle")
	self.Sprites.Burst:Load()
	self.Sprites.JetBottomLeft:Load()
	self.Sprites.JetBottomRight:Load()

	self.Sprites.Main.isVisible = true
	self.Sprites.Inner.isVisible = true
	self.Sprites.Glow.isVisible = true
	self.Sprites.Burst.isVisible = false
	self.Sprites.JetBottomLeft.isVisible = false
	self.Sprites.JetBottomRight.isVisible = false

	self.Sprites.Burst.alpha = 0.0
	self.Sprites.JetBottomLeft.alpha = 0.0
	self.Sprites.JetBottomRight.alpha = 0.0	

	self.Particles.Sparks:SetActive(true)
	self.Particles.HoverDust:SetActive(false)
	self.Particles.Streaks:SetActive(false)

	self:SetDrawHead(true)

	self.rotation = 0.0
	self.verticalSpeed = 0.0
	self.savedSpeed = 0.0
	self.burstStatus = 0.0
	self.isBursting = false
	self.isPressed = false
	self.isFiringBurst = false
	self.areJetsActive = false
	self.hasThrusterPlayed = false
	self.activeStatusLeds = 0

	local screenX, screenY = GetScreenSize()

	-- three lines below affect speed table position and are EDITABLE
	local speedTablePos = Vector.New(screenX * 0.2, screenY * -0.5 + 20)
	local speedTableBurstLeftOffset = Vector.New(-55, 0)
	local speedTableBurstRightOffset = Vector.New(56, 0)
	local speedTablePatchLeftOffset1 = Vector.New(-50, 0)
	local speedTablePatchLeftOffset2 = Vector.New(12, 0)
	local SpeedTablePatchesRightOffset1 = Vector.New(49, 0)
	local SpeedTablePatchesRightOffset2 = Vector.New(-12, 0)
	self.Sprites.SpeedTable:Load()
	self.Sprites.SpeedTable.isVisible = true
	self.Sprites.SpeedTable.pos = speedTablePos
	self.Sprites.SpeedTable:PlayAnimation("idle")
	self.Sprites.SpeedTableBurstLeft:Load()
	self.Sprites.SpeedTableBurstLeft.isVisible = false
	self.Sprites.SpeedTableBurstLeft.pos = speedTablePos + speedTableBurstLeftOffset
	self.Sprites.SpeedTableBurstLeft:PlayAnimation("burst")
	self.Sprites.SpeedTableBurstRight:Load()
	self.Sprites.SpeedTableBurstRight.isVisible = false
	self.Sprites.SpeedTableBurstRight.pos = speedTablePos + speedTableBurstRightOffset
	self.Sprites.SpeedTableBurstRight:PlayAnimation("burst")
	for i = 1, 7 do
		self.Sprites.SpeedTablePatchesLeft[i]:Load()
		self.Sprites.SpeedTablePatchesLeft[i].isVisible = true
		self.Sprites.SpeedTablePatchesLeft[i].pos = speedTablePos + speedTablePatchLeftOffset1 + speedTablePatchLeftOffset2 * (i - 4.5)
		self.Sprites.SpeedTablePatchesLeft[i]:PlayAnimation("idle")

		self.Sprites.SpeedTablePatchesRight[i]:Load()
		self.Sprites.SpeedTablePatchesRight[i].isVisible = true
		self.Sprites.SpeedTablePatchesRight[i].pos = speedTablePos + SpeedTablePatchesRightOffset1 + SpeedTablePatchesRightOffset2 * (i - 4.5)
		self.Sprites.SpeedTablePatchesRight[i]:PlayAnimation("idle")
	end

	self:UpdatePosition(0.0)

	SetVehicleScreenShotRating(50)
end

---
-- StopAllSounds()
--  Does what it says.
---
function Starship:StopAllSounds()
	self.Sounds.FormComplete:Stop(0.05)
	self.Sounds.Engine      :Stop(0.05)
	self.Sounds.Burst      :Stop(0.05)
	self.Sounds.Jets        :Stop(0.05)
	self.Sounds.Status       :Stop(0.05)
	self.Sounds.StatusFull      :Stop(0.05)
	self.Sounds.Thruster       :Stop(0.05)
	self.Sounds.BurstStart       :Stop(0.05)
	self.Sounds.BurstFinish       :Stop(0.05)

	self.Sounds.Death       :Stop(0.05)

	-- Go back to default track
	SFX.PlaySong("default", 2)
end

---
-- PickupSequenceUpdate()
--  ???
---
function Starship:PickupSequenceUpdate(dt)
	--Debug.Log(Debug.General, "Starship:PickupSequenceUpdate> dt:" .. tostring(dt))
end

---
-- Ready()
--  ???
---
function Starship:Ready(skipPickupSeq)
	Debug.Log(Debug.General, "Starship:Ready")
end

---
-- OnUpdate(dt)
--  Called from cpp, once per frame.
---
function Starship:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	self.Sprites.Main:Update(dt)
	self.Sprites.Inner:Update(dt)
	self.Sprites.Glow:Update(dt)
	self.Sprites.Burst:Update(dt)
	self.Sprites.JetBottomLeft:Update(dt)
	self.Sprites.JetBottomRight:Update(dt)
	self.Particles.Sparks:Update(self)
	self.Particles.HoverDust:Update(self)
	self.Particles.Streaks:Update(self)

	self.Sprites.SpeedTable:Update(dt)
	for i = 1, 7 do
		self.Sprites.SpeedTablePatchesLeft[i]:Update(dt)
		self.Sprites.SpeedTablePatchesRight[i]:Update(dt)
	end

	if (self.isBursting) then
		local BURST_TIME = 4.0
		self.burstStatus = self.burstStatus - dt / BURST_TIME

		if (self.burstStatus <= 0.0) then
			self.burstStatus = 0.0
			self.isBursting = false

			self:SetSpeed(self.savedSpeed)
			SetGameTimerFrozen(false)

			self:SetImmune(false)
			self:SetCollidable(true)

			Level.SetSpawningEnabled(true)
		end
	else
		local NON_BURST_TIME = 10.0
		self.burstStatus = self.burstStatus + dt / NON_BURST_TIME
		if (self.burstStatus >= 1.0) then
			self.burstStatus = 1.0
			self.isBursting = true

			self.savedSpeed = self:GetSpeed()
			SetGameTimerFrozen(true)

			self:SetImmune(true)
			self:SetCollidable(false)

			Level.SetSpawningEnabled(false)
		end
	end

	-- position updates
	if (self.isBursting) then
		self:UpdateBurst(dt)
	end
	self:UpdatePosition(dt)
	if (not self.isBursting) then
		VehicleUpdateSpeed(dt)
	end

	local newActiveLeds = 7
	for i = 1, 7 do
		local ledActive = not self.isBursting and (i / 7 > self.burstStatus)
		if (ledActive) then
			newActiveLeds = newActiveLeds - 1
		end
		self.Sprites.SpeedTablePatchesLeft[i].isVisible = ledActive
		self.Sprites.SpeedTablePatchesRight[i].isVisible = ledActive		
	end
	if (self.activeStatusLeds < newActiveLeds) then
		if (newActiveLeds < 7) then
			self.Sounds.Status:Play()
		else
			self.Sounds.StatusFull:Play()
		end
	end
	self.activeStatusLeds = newActiveLeds

	-- updates the magnet particles
	-- UpdateVehicleParticles()
end

---
-- UpdateBurst(<dt>)
--  Updates Starship's velocity during Burst
---
function Starship:UpdateBurst(dt)
	local SPEED_BONUS = 1500.0
	local SPEED_MULTIPLIER = 10.0
	local maxSpeed = SPEED_BONUS + self.savedSpeed * SPEED_MULTIPLIER
	local speed = maxSpeed

	local BURST_SPEED_UP = 0.3
	local BURST_SPEED_DOWN = 0.5
	if (self.burstStatus > BURST_SPEED_UP) then
		speed = Lerp.Sin.Tween(self.savedSpeed, maxSpeed, (1.0 - self.burstStatus) / (1.0 - BURST_SPEED_UP))
		if (not self.isFiringBurst) then
			self.isFiringBurst = true
			self.Sprites.SpeedTableBurstLeft:FadeIn()
			self.Sprites.SpeedTableBurstRight:FadeIn()
			self.Sprites.Burst:FadeIn()
			self.Sprites.Burst:PlayAnimation("idle")
			self.Sounds.Burst:Play()
			self.Sounds.BurstStart:Play()
			self.Sounds.Engine:Stop(0.5)

			self.Particles.Streaks:SetActive(true)
		end
	elseif (self.burstStatus < BURST_SPEED_DOWN) then
		speed = Lerp.Sin.Tween(maxSpeed, self.savedSpeed, 1.0 - self.burstStatus / BURST_SPEED_DOWN)
		if (self.isFiringBurst) then
			self.isFiringBurst = false
			self.Sprites.SpeedTableBurstLeft:FadeOut()
			self.Sprites.SpeedTableBurstLeft.isVisible = false
			self.Sprites.SpeedTableBurstRight:FadeOut()
			self.Sprites.SpeedTableBurstRight.isVisible = false

			self.Sprites.Burst:FadeOut()
			self.Sprites.Burst:PlayAnimation("die")
			self.Sounds.BurstFinish:Play()
			self.Sounds.Burst:Stop(0.05)
			self.Sounds.Engine:Play()

			self.Particles.Streaks:SetActive(false)
		end		
	end
	self:SetSpeed(speed)

	local RELATIVE_VELOCITY_CURVATURE = 0.0003 -- how fast we get to maximum distortion
	local MAX_RELATIVE_VELOCITY = 0.35 -- how relativistic everything is (0.0, 1.0)
	local relativeVelocity = (1 - math.exp(-(speed - self.savedSpeed) * RELATIVE_VELOCITY_CURVATURE)) * MAX_RELATIVE_VELOCITY

	local posX, posY = GetPlayerPosition()
	local screenX, screenY = GetScreenSize()
	local restX = GetVehicleRestPosition()

	local MAX_Y = 110
	local restOffset, textureOffset = self:GetRelativeOffsets(restX / screenX + 0.5, 0.5 + MAX_Y / screenX, relativeVelocity)
	posX = posX + ((restOffset - 0.5) * screenX - posX) * dt

	self:SetHorizontalOffset(textureOffset)
	self:SetRelativeVelocity(relativeVelocity)
	self:SetPostprocessPosition(posX / screenX + 0.5, -posY / screenY + 0.5)
end

---
-- UpdatePosition(<dt>)
--  Updates the Starship's position, velocity, and rotation.
---
function Starship:UpdatePosition(dt)
	local posX, posY = GetPlayerPosition()
	local restX = GetVehicleRestPosition()

	local THRUST_UP = 1100.0
	local THRUST_DOWN = -1850.0
	local MAX_ROTATION = 3
	local MAX_ANGLE_UP = 7
	local MAX_ANGLE_DOWN = -4
	local thrust = 0.0
	local desiredRotation = 0.0
	if (self.isPressed) then
		-- TODO show/hide jets
		thrust = THRUST_UP
		desiredRotation = MAX_ROTATION
		if (not self.areJetsActive) then
			self.Sprites.JetBottomLeft:FadeIn()
			self.Sprites.JetBottomRight:FadeIn()

			self.Sprites.Glow:PlayAnimation("glow_on")
			self.Sounds.Jets:Play()
			self.Sounds.Thruster:Play()
			self.areJetsActive = true
			self.hasThrusterPlayed = true

		elseif (not self.hasThrusterPlayed) then
			self.hasThrusterPlayed = true
		end
	else
		-- TODO show/hide jets
		thrust = THRUST_DOWN
		desiredRotation = -MAX_ROTATION

		if (self.areJetsActive and not self.isPressed) then
			self.Sprites.JetBottomLeft:FadeOut()
			self.Sprites.JetBottomRight:FadeOut()
			self.Sprites.Glow:PlayAnimation("glow_off")
			self.Sounds.Jets:Stop(0.05)
			self.Sounds.Thruster:Stop(0.05)
			self.areJetsActive = false
			self.Particles.HoverDust:SetActive(false)
		end		

		self.hasThrusterPlayed = false
	end

	local MAX_Y = 110
	local MIN_Y = -110
	posY = math.min(MAX_Y, math.max(MIN_Y, posY + self.verticalSpeed * dt))

	local REST_OFFSET = -30
	posX = posX + (restX + REST_OFFSET - posX) * dt

	local HOVER_Y = MIN_Y + 15.0
	if (posY < HOVER_Y) then
		local SPRING_CONSTANT = 795.0
		local SPEED_AMORTIZATION = 0.6
		local springAccel = SPRING_CONSTANT * (HOVER_Y - posY)
		self.verticalSpeed = (self.verticalSpeed + springAccel * dt) * SPEED_AMORTIZATION	
		local MAX_RECOIL_OFFSET = -20
		local RECOIL_POWER = 6
		local desiredX = restX + REST_OFFSET + MAX_RECOIL_OFFSET

		self.Particles.HoverDust:SetActive(true)

		posX = posX + (desiredX - posX) * (1.0 - math.pow(1.0 - (HOVER_Y - posY) / (HOVER_Y - MIN_Y), dt * RECOIL_POWER))
	end	

	local ROTATION_MARGIN = 40.0
	desiredRotation = desiredRotation * math.min(1.0, math.min(MAX_Y - posY, posY - MIN_Y) / ROTATION_MARGIN)

	local ROTATION_LATENCY = 0.1
	self.rotation = desiredRotation - (desiredRotation - self.rotation) * math.pow(0.5, dt / ROTATION_LATENCY)

	local MAX_VERTICAL_SPEED = 300.0
	local speedDelta = 0.0
	if (thrust > 0.0) then
		speedDelta = MAX_VERTICAL_SPEED - self.verticalSpeed
	else
		speedDelta = MAX_VERTICAL_SPEED + self.verticalSpeed
	end

	local ROTATION_FACTOR = 900.0
	self.verticalSpeed = self.verticalSpeed + (thrust + ROTATION_FACTOR * self.rotation / MAX_ROTATION) * dt * speedDelta / MAX_VERTICAL_SPEED

	local SPEED_MARGIN = 20.0
	self.verticalSpeed = math.min(self.verticalSpeed, MAX_VERTICAL_SPEED * (MAX_Y - posY) / SPEED_MARGIN)
	self.verticalSpeed = math.max(self.verticalSpeed, MAX_VERTICAL_SPEED * (MIN_Y - posY) / SPEED_MARGIN)

	SetPlayerPosition(posX, posY)

	self.Sprites.Main.pos = Vector.New(posX, posY)
	self.Sprites.Inner.pos = Vector.New(posX, posY)
	self.Sprites.Glow.pos = Vector.New(posX - 16, posY - 23)
	self.Sprites.Main.rotation = self.rotation
	self.Sprites.Inner.rotation = self.rotation
	-- TODO update sprite positions

	local jetPower = math.min(1, (math.max(0, desiredRotation - MAX_ANGLE_DOWN) / (MAX_ANGLE_UP - MAX_ANGLE_DOWN)))

	local JET_BASIC_SCALE = 2.0
	local JET_OFFSET = Vector.New(0, -32)
	local jetScale = Vector.New(0.8, JET_BASIC_SCALE + (1.0 - JET_BASIC_SCALE) * jetPower)

	self:UpdateSpritePosition(self.Sprites.Burst, Vector.New(-215, -20), Vector.New(0,0), Vector.New(1.0, 1,0))
	self:UpdateSpritePosition(self.Sprites.JetBottomLeft, Vector.New(-107, 3), JET_OFFSET, jetScale)
	self:UpdateSpritePosition(self.Sprites.JetBottomRight, Vector.New(75, -5), JET_OFFSET, jetScale)
end

---
-- GetRelativeOffsets
--  Calculates relativistic offsets for player and texture
---
function Starship:GetRelativeOffsets(right, y, relativeVelocity)
	local gamma = 1 / math.sqrt(1 - relativeVelocity ^ 2)
	local left = -1
	for i = 1, 20 do -- 2^-20 = 1e-6 error is surely small enough
		local x = (left + right) * 0.5
		local w = gamma * (1 - relativeVelocity * (1 - x - math.sqrt(y ^ 2 + x ^ 2)))
		if (w > 1) then
			right = x
		else
			left = x
		end
	end
	return left, -(1 - left) * (gamma * (1 - relativeVelocity) - 1)
end

---
-- UpdateSpritePosition(<sprite>, <pivot>, <offset>, <scale>)
--  Sets sprite's position, rotation and scale
---
function Starship:UpdateSpritePosition(sprite, pivot, offset, scale)
	sprite.scale = scale * self.scale
	sprite.pos = VectorMath.RotateVector((pivot + offset * scale) * self.scale, self.rotation) + Vector.New(GetPlayerPosition())
	sprite.rotation = self.rotation
end

---
-- OnDraw
--  Called from cpp
--  Draws all the things.
---
function Starship:OnDraw()

	-- Draw Base Texture
	self.Sprites.Main:Draw()
	self.Sprites.Inner:Draw()
	self.Sprites.Glow:Draw()
	self.Sprites.Burst:Draw()
	self.Sprites.JetBottomLeft:Draw()
	self.Sprites.JetBottomRight:Draw()

	self.Sprites.SpeedTable:Draw()
	self.Sprites.SpeedTableBurstLeft:Draw()
	self.Sprites.SpeedTableBurstRight:Draw()
	for i = 1, 7 do
		self.Sprites.SpeedTablePatchesLeft[i]:Draw()
		self.Sprites.SpeedTablePatchesRight[i]:Draw()
	end
end

---
-- GetShadowWidth
--  Returns the width of the drop shadow.
---
function Starship:GetShadowWidth()
	return 157.0
end

---
-- GetPlayerRectangle(<coin>)
--  Returns the player's bounds. (right, bottom, left, top)
--
-- Note: forCoin does not seem to be "for coins".
--       It looks like it's for destructible level objects and lights. meh.
---
function Starship:GetPlayerRectangle(forCoin)
	pos = Vector.New(GetPlayerPosition())
	return pos[1], pos[2], pos[1], pos[2] -- right, bottom, left, top
end

---
-- GetCollisionRectanglesCount()
--  Returns the amount of collision rectangles
---
function Starship:GetCollisionRectanglesCount()
	return 2
end

---
-- GetCollisionRectangle(<index>)
--  Returns the player's collision bounds (x, y, width, height)
---
function Starship:GetCollisionRectangle(index)
	-- x pos, y pos, x extent, y extent
	local px, py, ex, ey
	if (index == 0) then
		px, py, ex, ey = -25, 0, 65, 35
	else
		px, py, ex, ey = 60, 0, 20, 20
	end
	return px * self.scale[1], py * self.scale[2], ex * self.scale[1], ey * self.scale[2]
end

---
-- GetRotation()
---
function Starship:GetRotation()
	return self.rotation
end

---
-- GetRenderOffset()
---
function Starship:GetRenderOffset()
	return 0, 0
end

---
-- TouchUp()
---
function Starship:TouchUp()
	self.isPressed = false
end

---
-- TouchDown()
---
function Starship:TouchDown()
	self.isPressed = true
end

---
-- Explode()
--  Called from cpp, when the Vehicle should blow up.
---
function Starship:Explode()
	Debug.Log(Debug.General, "Starship:Explode")
	self.Sounds.Death:Play()
	self.Particles.Sparks:SetActive(false)
	self.Particles.HoverDust:SetActive(false)
	self.Particles.Streaks:SetActive(false)
	self:CloseAll()
end

---
-- OnDestroy()
--  Called from cpp, when the Vehicle has been destroyed.
---
function Starship:OnDestroy(didQuit)
	Debug.Log(Debug.General, "Starship:OnDestroy")
	self.Particles.Sparks:DestroyEmitter()
	self.Particles.HoverDust:DestroyEmitter()
	self.Particles.Streaks:DestroyEmitter()
	self.Base.OnDestroy(self)
	self:CloseAll()
end

---
-- CloseAll
--  Called on script close.
---
function Starship:CloseAll()
	self:StopAllSounds()

	-- No longer immune, and is collidable
	self:SetImmune(false)
	self:SetCollidable(true)

	-- Start Spawning again
	Level.SetSpawningEnabled(true)
end

RegisterVehicle("Starship", "StarshipBase", Starship)
