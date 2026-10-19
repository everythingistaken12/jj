Log("Ecto Lua script started v1.2.36")

EctoBuilder = {}

function EctoBuilder.GetSkinFolder(skin)
	return "textures/Characters/Vehicles/Ecto/"..skin.."/"
end

function EctoBuilder.Build(skin)
	-- The Ecto itself
	local Ecto = {}

	-- Ecto members
	Ecto.rotation = 0.0
	Ecto.verticalSpeed = 0.0
	Ecto.savedSpeed = 0.0
	Ecto.burstStatus = 0.0 -- [0.0, 1.0]
	Ecto.isBursting = false
	Ecto.isPressed = false
	Ecto.scale = Vector.New(0.9, 0.9) -- EDITABLE
	-- visuals
	Ecto.isFiringBurst     = false
	Ecto.areJetsActive     = false
	Ecto.hasThrusterPlayed = false
	Ecto.activeStatusLeds  = 0

	---
	-- Ecto Sounds
	---
	Ecto.Sounds = {}

	-- to play when the vehicle has finished forming
	Ecto.Sounds.FormComplete = Sound.new("ecto_form_complete")

	-- looping sound to play while the Ecto is active. I think this should continue to play while it's in the air, but we'll have to see how it sounds
	Ecto.Sounds.Engine   = Sound.new("ecto_engine_lp", true, 1.0)
	Ecto.Sounds.Jets     = Sound.new("ecto_jets_lp", true, 1.0)
	Ecto.Sounds.Burst    = Sound.new("ecto_burst_lp", true, 1.0)
	Ecto.Sounds.Siren    = Sound.new("ecto_siren_lp", true, 1.0)

	-- one time effects
	Ecto.Sounds.Status      = Sound.new("ecto_speed_meter")
	Ecto.Sounds.StatusFull  = Sound.new("ecto_speed_meter_full")
	Ecto.Sounds.Land        = Sound.new("ecto_land")
	Ecto.Sounds.Jump        = Sound.new("ecto_jump")
	Ecto.Sounds.BurstStart  = Sound.new("ecto_full_speed_boost")
	Ecto.Sounds.Shockwave   = Sound.new("ecto_full_speed_shockwave")
	Ecto.Sounds.Thruster    = Sound.new("ecto_thruster")

	-- to play when it is destroyed
	Ecto.Sounds.Death      = Sound.new("ecto_death")
	Ecto.Sounds.SirenOff   = Sound.new("ecto_siren_off")

	local skinFolder = EctoBuilder.GetSkinFolder(skin)

	---
	-- Ecto sprites
	---
	Ecto.Sprites = {}
	Ecto.Sprites.Main       = Sprite.New(skinFolder.."ecto.xml", 11)
	Ecto.Sprites.Inner      = Sprite.New(skinFolder.."ecto_inside.xml", 9)
	-- Jets left to right
	Ecto.Sprites.Jet1       = Sprite.New(skinFolder.."ecto_jet.xml", 11)
	Ecto.Sprites.Jet2       = Sprite.New(skinFolder.."ecto_jet.xml", 11)
	Ecto.Sprites.Jet3       = Sprite.New(skinFolder.."ecto_jet.xml", 11)
	Ecto.Sprites.Jet4       = Sprite.New(skinFolder.."ecto_jet.xml", 11)
	Ecto.Sprites.Burst      = Sprite.New(skinFolder.."ecto_burst.xml", 10)
	Ecto.Sprites.Siren      = Sprite.New(skinFolder.."ecto_siren.xml", 12)
	-- Wheels
	Ecto.Sprites.Wheel1     = Sprite.New(skinFolder.."ecto_wheel1.xml", 10)
	Ecto.Sprites.Wheel2     = Sprite.New(skinFolder.."ecto_wheel2.xml", 10)
	-- UI stuff
	Ecto.Sprites.SpeedTable = Sprite.New(skinFolder.."speedtable2.xml", 11)
	Ecto.Sprites.SpeedTableBurst = Sprite.New(skinFolder.."speedtable_burst.xml", 14)
	Ecto.Sprites.SpeedTablePatches = {}
	for i = 1, 8 do
		Ecto.Sprites.SpeedTablePatches[i] = Sprite.New(skinFolder.."speedtable_patch.xml", 13)
	end

	Ecto.Sprites.Main.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Inner.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Jet1.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Jet2.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Jet3.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Jet4.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Burst.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Siren.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Wheel1.scale = Vector.Clone(Ecto.scale)
	Ecto.Sprites.Wheel2.scale = Vector.Clone(Ecto.scale)

	---
	-- Ecto Particles
	---
	Ecto.Particles = {}
	-- Ecto.Particles.Sparks = Particle.new("Ecto_Sparks", Vector.New(0, 0), ParticleLTWType.ScreenRelative, true)

	---
	-- GetTextureList()
	--  Called from cpp.
	---
	function Ecto.GetTextureList()
		return
			skinFolder.."ecto.tex" ..
			"|"..skinFolder.."ecto_bg.tex" ..
			"|"..skinFolder.."ecto_jet.tex" ..
			"|"..skinFolder.."ecto_burst.tex" ..
			"|"..skinFolder.."ecto_siren.tex" ..
			"|"..skinFolder.."ecto_wheel1.tex" ..
			"|"..skinFolder.."ecto_wheel2.tex" ..
			"|"..skinFolder.."ecto_siren.tex" ..
			"|"..skinFolder.."speedtable2.tex" ..
			"|"..skinFolder.."speedtable_burst.tex" ..
			"|"..skinFolder.."speedtable_patch.tex"
	end

	---
	-- PickupStart()
	--  ???
	---
	function Ecto:PickupStart()
		Debug.Log(Debug.General, "Ecto:PickupStart")
		-- OffsetPickupComponents(2,18)
		SetFirstComponentToFront(true)
		self.Sounds.Siren:Play()
	end

	---
	-- ConstructionComplete()
	--  Called from cpp, when the Ecto has finished being constructed.
	---
	function Ecto:ConstructionComplete()
		Debug.Log(Debug.General, "Ecto:ConstructionComplete")
		self.Sounds.FormComplete:Play()
		self.Sounds.Engine:Play()
		self.Sounds.Siren:Stop(0.5)
		OffsetVehiclePosition(0,0)
	end

	---
	-- OnInit
	--  Called from cpp when the Vehicle has just been Initialized.
	--
	-- Note: The Vehicle may be drawn before its first update.
	--       So, make sure that its state is presentable.
	---
	function Ecto:OnInit(info)
		Debug.Log(Debug.General, "Ecto:OnInit")
		self.Base.OnInit(self, info)

		-- Load Main body
		self.Sprites.Main:Load()
		self.Sprites.Inner:Load()
		self.Sprites.Jet1:Load()
		self.Sprites.Jet2:Load()
		self.Sprites.Jet3:Load()
		self.Sprites.Jet4:Load()
		self.Sprites.Burst:Load()
		self.Sprites.Siren:Load()
		self.Sprites.Wheel1:Load()
		self.Sprites.Wheel2:Load()

		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Jet1.isVisible = false
		self.Sprites.Jet2.isVisible = false
		self.Sprites.Jet3.isVisible = false
		self.Sprites.Jet4.isVisible = false
		self.Sprites.Burst.isVisible = false
		self.Sprites.Siren.isVisible = false
		self.Sprites.Jet1.alpha = 0.0
		self.Sprites.Jet2.alpha = 0.0
		self.Sprites.Jet3.alpha = 0.0
		self.Sprites.Jet4.alpha = 0.0
		self.Sprites.Burst.alpha = 0.0
		self.Sprites.Siren.alpha = 0.0
		self.Sprites.Wheel1.isVisible = true
		self.Sprites.Wheel2.isVisible = true

		self.Sprites.Wheel1:PlayAnimation("idle")
		self.Sprites.Wheel2:PlayAnimation("idle")


		local screenX, screenY = GetScreenSize()
		-- three lines below affect speed table position and are EDITABLE
		local speedTablePos = Vector.New(screenX * 0.2, screenY * -0.5 + 20)
		local speedTablePatchOffset1 = Vector.New(0, -0.5)
		local speedTablePatchOffset2 = Vector.New(15, 0)
		self.Sprites.SpeedTable:Load()
		self.Sprites.SpeedTable.isVisible = true
		self.Sprites.SpeedTable.pos = speedTablePos
		self.Sprites.SpeedTable:PlayAnimation("idle")
		self.Sprites.SpeedTableBurst:Load()
		self.Sprites.SpeedTableBurst.isVisible = false
		self.Sprites.SpeedTableBurst.pos = speedTablePos
		self.Sprites.SpeedTableBurst:PlayAnimation("idle")
		for i = 1, 8 do
			self.Sprites.SpeedTablePatches[i]:Load()
			self.Sprites.SpeedTablePatches[i].isVisible = true
			self.Sprites.SpeedTablePatches[i].pos = speedTablePos + speedTablePatchOffset1 + speedTablePatchOffset2 * (i - 4.5)
			self.Sprites.SpeedTablePatches[i]:PlayAnimation("idle")
		end

		-- self.Particles.Sparks:SetActive(true)

		self:SetDrawHead(true)

		self.rotation = 0.0
		self.verticalSpeed = 0.0
		self.burstStatus = 0.0
		self.isBursting = false
		self.isPressed = false
		self.isFiringBurst = false
		self.areJetsActive = false
		self.hasThrusterPlayed = false
		self.activeStatusLeds = 0

		self:UpdatePosition(0.0)

		SetVehicleScreenShotRating(50)
	end

	---
	-- StopAllSounds()
	--  Does what it says.
	---
	function Ecto:StopAllSounds()
		self.Sounds.FormComplete:Stop(0.05)
		self.Sounds.Engine      :Stop(0.05)
		self.Sounds.Jets        :Stop(0.05)
		self.Sounds.Burst       :Stop(0.05)
		self.Sounds.Siren       :Stop(0.05)
		self.Sounds.Status      :Stop(0.05)
		self.Sounds.StatusFull  :Stop(0.05)
		self.Sounds.Land        :Stop(0.05)
		self.Sounds.Jump        :Stop(0.05)
		self.Sounds.BurstStart  :Stop(0.05)
		self.Sounds.Shockwave   :Stop(0.05)
		self.Sounds.Thruster    :Stop(0.05)
		self.Sounds.Death       :Stop(0.05)
		self.Sounds.SirenOff    :Stop(0.05)

		-- Go back to default track
		SFX.PlaySong("default", 2)
	end

	---
	-- PickupSequenceUpdate()
	--  ???
	---
	function Ecto:PickupSequenceUpdate(dt)
		--Debug.Log(Debug.General, "Ecto:PickupSequenceUpdate> dt:" .. tostring(dt))
	end

	---
	-- Ready()
	--  ???
	---
	function Ecto:Ready(skipPickupSeq)
		Debug.Log(Debug.General, "Ecto:Ready")
	end

	---
	-- OnUpdate(dt)
	--  Called from cpp, once per frame.
	---
	function Ecto:OnUpdate(dt)
		self.Sprites.Main:Update(dt)
		self.Sprites.Inner:Update(dt)
		self.Sprites.Jet1:Update(dt)
		self.Sprites.Jet2:Update(dt)
		self.Sprites.Jet3:Update(dt)
		self.Sprites.Jet4:Update(dt)
		self.Sprites.Burst:Update(dt)
		self.Sprites.Siren:Update(dt)
		self.Sprites.Wheel1:Update(dt)
		self.Sprites.Wheel2:Update(dt)

		self.Sprites.SpeedTable:Update(dt)
		for i = 1, 8 do
			self.Sprites.SpeedTablePatches[i]:Update(dt)
		end

		-- Update burst status and switch if needed
		if (self.isBursting) then
			local BURST_TIME = 4.0 -- EDITABLE
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
			local NON_BURST_TIME = 8.0 -- EDITABLE
			self.burstStatus = self.burstStatus + dt / NON_BURST_TIME
			if (self.burstStatus >= 1.0) then
				self.burstStatus = 1.0
				self.isBursting = true
			
				self.Sprites.Siren:FadeIn()
				self.Sounds.Siren:Play()
				self.Sounds.Shockwave:Play()

				self.savedSpeed = self:GetSpeed()
				SetGameTimerFrozen(true)

				self:SetImmune(true)
				self:SetCollidable(false)
				
				Level.ClearObstacles()
				Level.ClearMissiles()
				Level.SetSpawningEnabled(false)

				local posX, posY = GetPlayerPosition()
				Level.CreateShockwave(posX, posY, true)
			end
		end

		-- Move stuff
		if (self.isBursting) then
			self:UpdateBurst(dt)
		end
		self:UpdatePosition(dt)
		if (not self.isBursting) then
			VehicleUpdateSpeed(dt)
		end

		local newActiveLeds = 8
		for i = 1, 8 do
			local ledActive = not self.isBursting and (i / 8 > self.burstStatus)
			if (ledActive) then
				newActiveLeds = newActiveLeds - 1
			end
			self.Sprites.SpeedTablePatches[i].isVisible = ledActive
		end
		if (self.activeStatusLeds < newActiveLeds) then
			if (newActiveLeds < 8) then
				self.Sounds.Status:Play()
			else
				self.Sounds.StatusFull:Play()
			end
		end
		self.activeStatusLeds = newActiveLeds

		-- updates the magnet particles
		-- UpdateVehicleParticles()
		-- self.Particles.Sparks:Update(self)
	end

	---
	-- UpdateBurst(<dt>)
	--  Updates the Ecto's position, velocity, and rotation during Burst
	---
	function Ecto:UpdateBurst(dt) -- EDITABLE all upper case variables
		local SPEED_BONUS = 1500.0
		local SPEED_MULTIPLIER = 10.0
		local maxSpeed = SPEED_BONUS + self.savedSpeed * SPEED_MULTIPLIER
		local speed = maxSpeed

		local BURST_WAIT = 1.0 -- when status is greater than
		local BURST_SPEED_UP = 0.4 -- when status is greater than
		local BURST_SPEED_DOWN = 0.3 -- when status is less than
		if (self.burstStatus > BURST_WAIT) then
			speed = self.savedSpeed
		elseif (self.burstStatus > BURST_SPEED_UP) then
			speed = Lerp.Sin.Tween(self.savedSpeed, maxSpeed, (BURST_WAIT - self.burstStatus) / (BURST_WAIT - BURST_SPEED_UP))
			if (not self.isFiringBurst) then
				self.isFiringBurst = true
				self.Sprites.Burst:FadeIn()
				self.Sprites.SpeedTableBurst:FadeIn()
				self.Sounds.Burst:Play()
				self.Sounds.BurstStart:Play()
			end
		elseif (self.burstStatus < BURST_SPEED_DOWN) then
			speed = Lerp.Sin.Tween(maxSpeed, self.savedSpeed, 1.0 - self.burstStatus / BURST_SPEED_DOWN)
			if (self.isFiringBurst) then
				self.isFiringBurst = false
				self.Sprites.Burst:FadeOut()
				self.Sprites.SpeedTableBurst:FadeOut()
				self.Sprites.SpeedTableBurst.isVisible = false
				self.Sprites.Siren:FadeOut()
				self.Sounds.Burst:Stop(0.05)
				self.Sounds.Siren:Stop(0.05)
				self.Sounds.SirenOff:Play()
				
			end
		end
		self:SetSpeed(speed)
		local BURST_BASIC_SOUND = 0.3
		if (self.Sounds.Burst.isActive) then
			self.Sounds.Burst:SetVolume(BURST_BASIC_SOUND + (1.0 - BURST_BASIC_SOUND) * (1.0 - (maxSpeed - speed) / (maxSpeed - self.savedSpeed)))
		end
	end

	---
	-- UpdatePosition(<dt>)
	--  Updates the Ecto's position, velocity, and rotation.
	---
	function Ecto:UpdatePosition(dt)
		local posX, posY = GetPlayerPosition()
		local restX = GetVehicleRestPosition()

		-- THIS BLOCK WAS BORROWED FROM DELOREAN AND AFFECT GAMEPLAY
		-- THERE ARE SOME DIFFERENCES THOUGH :)
		-- !!! BLOCK BEGIN

		local ACCEL_UP = 1200.0
		local ACCEL_DOWN = -750.0
		local accel = 0.0
		if (self.isPressed) then
			if (not self.areJetsActive) then
				self.Sprites.Jet1:FadeIn()
				self.Sprites.Jet2:FadeIn()
				self.Sprites.Jet3:FadeIn()
				self.Sprites.Jet4:FadeIn()
				self.Sounds.Jets:Play()
				self.Sounds.Jump:Play()
				self.Sounds.Engine:Stop(0.05)
				self.areJetsActive = true
				self.hasThrusterPlayed = true
			elseif (not self.hasThrusterPlayed) then
				self.Sounds.Thruster:Play()
				self.hasThrusterPlayed = true
			end
			accel = ACCEL_UP
		else
			self.hasThrusterPlayed = false
			accel = ACCEL_DOWN
		end

		local MAX_SPEED_UP = 200.0
		local MAX_SPEED_DOWN = -520.0
		self.verticalSpeed = math.min(MAX_SPEED_UP, math.max(MAX_SPEED_DOWN, self.verticalSpeed + accel * dt))

		local MAX_Y = 112
		local MIN_Y = -112
		posY = posY + self.verticalSpeed * dt
		if (posY >= MAX_Y and self.verticalSpeed > 0) then
			posY = MAX_Y
			self.verticalSpeed = 0
		end
		if (posY <= MIN_Y and self.verticalSpeed < 0) then
			posY = MIN_Y
			self.verticalSpeed = 0
		end

		local REST_OFFSET = -30
		posX = posX + (restX + REST_OFFSET - posX) * dt

		local HOVER_Y = MIN_Y + 15.0
		if (posY < HOVER_Y) then
			local SPRING_CONSTANT = 795.0
			local SPEED_AMORTIZATION = 0.6
			local springAccel = SPRING_CONSTANT * (HOVER_Y - posY)
			self.verticalSpeed = (self.verticalSpeed + springAccel * dt) * SPEED_AMORTIZATION
			if (self.areJetsActive and not self.isPressed) then
				self.Sprites.Jet1:FadeOut()
				self.Sprites.Jet2:FadeOut()
				self.Sprites.Jet3:FadeOut()
				self.Sprites.Jet4:FadeOut()
				self.Sounds.Jets:Stop(0.05)
				self.Sounds.Land:Play()
				self.Sounds.Engine:Play()
				self.areJetsActive = false
			end
			local MAX_RECOIL_OFFSET = -20
			local RECOIL_POWER = 6
			local desiredX = restX + REST_OFFSET + MAX_RECOIL_OFFSET
			posX = posX + (desiredX - posX) * (1.0 - math.pow(1.0 - (HOVER_Y - posY) / (HOVER_Y - MIN_Y), dt * RECOIL_POWER))
		end

		local MAX_ANGLE_UP = 7
		local MAX_ANGLE_DOWN = -4
		local desiredRotation = 0.0
		if (self.verticalSpeed > 0) then
			desiredRotation = MAX_ANGLE_UP * self.verticalSpeed / MAX_SPEED_UP
			local MAX_ROTATION_Y = 64
			if (posY > MAX_ROTATION_Y) then
				desiredRotation = Lerp.Sin.Tween(desiredRotation, 0.0, (posY - MAX_ROTATION_Y) / (MAX_Y - MAX_ROTATION_Y))
			end
		else
			local MIN_ROTATION_Y = -64
			desiredRotation = MAX_ANGLE_DOWN * self.verticalSpeed / MAX_SPEED_DOWN
			if (posY < MIN_ROTATION_Y) then
				desiredRotation = Lerp.Sin.Tween(desiredRotation, 0.0, (posY - MIN_ROTATION_Y) / (MIN_Y - MIN_ROTATION_Y))
			end
		end

		local ROTATION_CHANGE_SPEED = 0.15
		self.rotation = Lerp.EaseOutSin.Tween(self.rotation, desiredRotation, ROTATION_CHANGE_SPEED)

		SetPlayerPosition(posX, posY)
		self.Sprites.Main.pos = Vector.New(posX, posY)
		self.Sprites.Inner.pos = Vector.New(posX, posY)
		self.Sprites.Main.rotation = self.rotation
		self.Sprites.Inner.rotation = self.rotation

		-- !!! BLOCK END
		-- Constants below affect only effects
		-- EDITABLE upper case variables 

		local jetPower = math.min(1, (math.max(0, desiredRotation - MAX_ANGLE_DOWN) / (MAX_ANGLE_UP - MAX_ANGLE_DOWN)))

		local JET_BASIC_SCALE = 0.1
		local JET_OFFSET = Vector.New(0, -32)
		local jetScale = Vector.New(0.8, JET_BASIC_SCALE + (1.0 - JET_BASIC_SCALE) * jetPower)
		-- EDITABLE feel free to edit coordinates
		self:UpdateSpritePosition(self.Sprites.Jet1, Vector.New(-61, -36), JET_OFFSET, jetScale)
		self:UpdateSpritePosition(self.Sprites.Jet2, Vector.New(-40, -36), JET_OFFSET, jetScale)
		self:UpdateSpritePosition(self.Sprites.Jet3, Vector.New(59, -34), JET_OFFSET, jetScale)
		self:UpdateSpritePosition(self.Sprites.Jet4, Vector.New(88, -34), JET_OFFSET, jetScale)
		self:UpdateSpritePosition(self.Sprites.Burst, Vector.New(-123, -10), Vector.New(0, 0), Vector.New(1, 1))
		self:UpdateSpritePosition(self.Sprites.Siren, Vector.New(-16.5, 11), Vector.New(0, 0), Vector.New(1, 1))

		local rotationSpeed = desiredRotation - self.rotation
		local wheelsBasicStress = 0
		if (self.verticalSpeed > 0) then
			wheelsBasicStress = self.verticalSpeed / MAX_SPEED_UP
		else
			wheelsBasicStress = -1 * self.verticalSpeed / MAX_SPEED_DOWN
		end
		-- EDITABLE values in two lines below
		local wheel1Stress = (wheelsBasicStress + rotationSpeed * -0.5) * 2
		local wheel2Stress = (wheelsBasicStress + rotationSpeed * 1.0) * 2

		local WHEELS_MAX_OFFSET = -30
		-- EDITABLE first coordinate
		self:UpdateSpritePosition(self.Sprites.Wheel1, Vector.New(-50, WHEELS_MAX_OFFSET - wheel1Stress), Vector.New(0, 0), Vector.New(1, 1))
		self:UpdateSpritePosition(self.Sprites.Wheel2, Vector.New(73, WHEELS_MAX_OFFSET - wheel2Stress), Vector.New(0, 0), Vector.New(1, 1))

		local wheelMinY = HOVER_Y + WHEELS_MAX_OFFSET * self.scale[2]
		self.Sprites.Wheel1.pos[2] = math.max(self.Sprites.Wheel1.pos[2], wheelMinY)
		self.Sprites.Wheel2.pos[2] = math.max(self.Sprites.Wheel2.pos[2], wheelMinY)
		
		if (self.areJetsActive and self.Sounds.Jets.isActive) then
			local JET_BASIC_SOUND = 0.3
			self.Sounds.Jets:SetVolume(JET_BASIC_SOUND + (1.0 - JET_BASIC_SOUND) * jetPower)
		end
	end

	---
	-- UpdateSpritePosition(<sprite>, <pivot>, <scale>)
	--  Sets sprite's position, rotation and scale
	---
	function Ecto:UpdateSpritePosition(sprite, pivot, offset, scale)
		sprite.scale = Vector.Clone(scale * self.scale)
		sprite.pos = VectorMath.RotateVector((pivot + offset * scale) * self.scale, self.rotation) + Vector.New(GetPlayerPosition())
		sprite.rotation = self.rotation
	end

	---
	-- OnDraw
	--  Called from cpp
	--  Draws all the things.
	---
	function Ecto:OnDraw()
		self.Sprites.Main:Draw()
		self.Sprites.Inner:Draw()
		self.Sprites.Jet1:Draw()
		self.Sprites.Jet2:Draw()
		self.Sprites.Jet3:Draw()
		self.Sprites.Jet4:Draw()
		self.Sprites.Burst:Draw()
		self.Sprites.Siren:Draw()
		self.Sprites.Wheel1:Draw()
		self.Sprites.Wheel2:Draw()

		self.Sprites.SpeedTable:Draw()
		self.Sprites.SpeedTableBurst:Draw()
		for i = 1, 8 do
			self.Sprites.SpeedTablePatches[i]:Draw()
		end
	end

	---
	-- GetShadowWidth
	--  Returns the width of the drop shadow.
	---
	function Ecto:GetShadowWidth()
		return 197.0
	end

	---
	-- GetPlayerRectangle(<coin>)
	--  Returns the player's bounds. (right, bottom, left, top)
	--
	-- Note: forCoin does not seem to be "for coins".
	--       It looks like it's for destructible level objects and lights. meh.
	---
	function Ecto:GetPlayerRectangle(forCoin)
		pos = Vector.New(GetPlayerPosition())
		return pos[1], pos[2], pos[1], pos[2] -- right, bottom, left, top
	end

	---
	-- GetCollisionRectanglesCount()
	--  Returns the amount of collision rectangles
	---
	function Ecto:GetCollisionRectanglesCount()
		return 3
	end

	---
	-- GetCollisionRectangle(<index>)
	--  Returns the player's collision bounds (x, y, width, height)
	---
	function Ecto:GetCollisionRectangle(index)
		-- x pos, y pos, x extent, y extent
		local px, py, ex, ey
		if (index == 0) then
			px, py, ex, ey = 0, -25, 100, 15 -- biggest
		elseif (index == 1) then
			px, py, ex, ey = -20, 0, 60, 10 -- middle one
		else
			px, py, ex, ey = -30, 16, 30, 6 -- smallest, geez
		end
		return px * self.scale[1], py * self.scale[2], ex * self.scale[1], ey * self.scale[2]
	end

	---
	-- GetRotation()
	---
	function Ecto:GetRotation()
		return self.rotation
	end

	---
	-- GetRenderOffset()
	---
	function Ecto:GetRenderOffset()
		return 0, 0
	end

	---
	-- TouchUp()
	---
	function Ecto:TouchUp()
		self.isPressed = false
	end

	---
	-- TouchDown()
	---
	function Ecto:TouchDown()
		self.isPressed = true
	end

	---
	-- Explode()
	--  Called from cpp, when the Vehicle should blow up.
	---
	function Ecto:Explode()
		Debug.Log(Debug.General, "Ecto:Explode")
		self.Sounds.Death:Play()
		-- self.Particles.Sparks:SetActive(false)
		self:CloseAll()
	end

	---
	-- OnDestroy()
	--  Called from cpp, when the Vehicle has been destroyed.
	---
	function Ecto:OnDestroy(didQuit)
		Debug.Log(Debug.General, "Ecto:OnDestroy")
		-- self.Particles.Sparks:DestroyEmitter()
		self.Base.OnDestroy(self)
		self:CloseAll()
	end

	---
	-- CloseAll
	--  Called on script close.
	---
	function Ecto:CloseAll()
		self:StopAllSounds()

		-- No longer immune, and is collidable
		self:SetImmune(false)
		self:SetCollidable(true)

		-- Start Spawning again
		Level.SetSpawningEnabled(true)
	end

	return Ecto
end

RegisterVehicle("Ecto", "EctoBase", EctoBuilder.Build("Ecto"))
