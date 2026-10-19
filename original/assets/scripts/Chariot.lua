Log("Chariot Lua script started")

ChariotBuilder = {}

function ChariotBuilder.Build(skin, overloadVehicleSounds, overloadPickupSounds, overloadEffects)
	local Chariot = {}

	Chariot.headPos = Vector.New(0,0)
	Chariot.lastAnimationFrame = 0
	Chariot.startNeigh = false
	Chariot.playFallingSound = false
	Chariot.fallingSound = -1
	Chariot.playGroundSound = false
	Chariot.groundSound = false
	Chariot.neighCounter = 0
	Chariot.rainbowSin = 0

	function Chariot.GetTextureList()
		return "textures/Characters/Vehicles/Components/Sled/"..skin.."/componentBackWing.tex"..
			"|textures/Characters/Vehicles/sled/"..skin.."/chariotWing.tex"..
			"|textures/Characters/Vehicles/sled/"..skin.."/chariotWingBack.tex"..
			"|textures/Effects/Jetpack/rainbowSparkle.tex"..
			"|textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetTransition.tex"..
			"|textures/Characters/RobotDog/Vehicles/"..skin.."/sledAntlers.tex"
	end

	function Chariot:BannerComplete()
		VehicleUtils.PlaySong(self, "music", "banner_complete")
	end

	function Chariot.PickupStart()
		OffsetPickupComponents(4,-5)
		OffsetChildPickupComponents(5,0)
		SetFirstComponentToFront(false)
		SetChildComponentToFront(false)
	end

	function Chariot:ComponentComplete(vehicleType)
		Log("Component!")
		
	end

	function Chariot:ConstructionComplete(vehicleType)
		if(vehicleType == "Reindeer")then
			if(self.startNeigh == false)then
				Log("Neigh! "..tostring(vehicleType))
				SFX.PlaySound("chariot_form_complete")
				self.startNeigh = true
				OffsetVehiclePosition(19,-9)
				UpdateVehicle()
				SetBarryOffset(-16,5)
			end
		end
		VehicleUtils.PlaySong(self, "music", "construction_complete")
	end

	function Chariot:OnInit(info)
		self.Base.OnInit(self, info)
		
		self.playGroundSound = false
		self.startNeigh = false
		self.rainbowSin = 10
		SetDrawOffset(5,-5)
		SetDeerOffset(2,0)
		SetSleighOffset(-4,-1)
		SetSleighAnimation("easeIn", "")
		SetSleighAnimation("easeOut", "")
		SetSleighAnimation("jump", "jump")
		SetSleighAnimation("land", "land")
		SetDrawBody(true)

		if (overloadVehicleSounds) then
			OverloadVehicleSounds()
		end

		if (overloadPickupSounds) then
			OverloadPickupSounds()
		end

		self.chariotWing = LoadTexture("textures/Characters/Vehicles/Sled/"..skin.."/ChariotWing.xml", 12)
		self.chariotWingBack = LoadTexture("textures/Characters/Vehicles/Sled/"..skin.."/ChariotWingBack.xml", 10)
		self.puppyWings = LoadTexture("textures/Characters/RobotDog/Vehicles/"..skin.."/PuppyWings.xml", 14)
		Log("Init Particles!") 

		if (overloadEffects) then
			SetSledEffects(false)
		end

		self.horseOneRainbowTrail = CreateRainbowTrail(0,0, false, false, self.rainbowSin)
		self.horseTwoRainbowTrail = CreateRainbowTrail(0,0, false, false, self.rainbowSin)
		SetRainbowFadeDist(self.horseOneRainbowTrail, 60)
		SetRainbowFadeDist(self.horseTwoRainbowTrail, 60)
		SetRainbowFadeSpeed(self.horseOneRainbowTrail, 10)
		SetRainbowFadeSpeed(self.horseTwoRainbowTrail, 10)
		AddPickupComponent("textures/Characters/Vehicles/Components/Sled/"..skin.."/componentBackWing.tex", 4)
	end

	function Chariot.PickupSequenceUpdate(dt)
	end

	function Chariot:Ready(skipPickupSeq)
		Log("Ready")
		VehicleUtils.PlaySong(self, "music", "ready")
		
		if(skipPickupSeq)then
			SetBarryOffset(-16,5)
		end
		
		self.horseOneParticle = CreateParticle("horse_puff")
		self.horseTwoParticle = CreateParticle("horse_puff")
		self.chariotParticle = CreateParticle("horse_puff")
		self.horseOneRainbowParticle = CreateParticle("horse_rainbow")
		self.horseTwoRainbowParticle = CreateParticle("horse_rainbow")
		SetParticleEnabled(self.horseOneParticle, false)
		SetParticleEnabled(self.horseTwoParticle, false)
		SetParticleEnabled(self.chariotParticle, false)
		SetParticleEnabled(self.horseOneRainbowParticle, false)
		SetParticleEnabled(self.horseTwoRainbowParticle, false)
		
	end

	function Chariot:OnUpdate(dt)
		self.Base.OnUpdate(self, dt)
		
		anim, animationFrame = GetDeerAnimation()
		if(anim == "fly")then

			if(animationFrame == 4 and self.lastAnimationFrame ~= 4)then
				ChariotFlap()
				SetParticleEnabled(self.horseOneParticle, true)
				SetParticleEnabled(self.horseTwoParticle, true)
				SetParticleEnabled(self.chariotParticle, true)
			end
			if(animationFrame == 6 and self.lastAnimationFrame ~= 6)then
				SetParticleEnabled(self.horseOneParticle, false)
				SetParticleEnabled(self.horseTwoParticle, false)
				SetParticleEnabled(self.chariotParticle, false)
			end
		elseif(anim == "fall")then
			if(animationFrame == 5 and self.lastAnimationFrame ~= 5)then	
				ChariotFlap()
			end
		elseif(anim == "jump")then
			if(animationFrame == 1 and self.lastAnimationFrame ~= 1)then
				ChariotFlap()
				SetParticleEnabled(self.horseOneParticle, true)
				SetParticleEnabled(self.horseTwoParticle, true)
				SetParticleEnabled(self.chariotParticle, true)
			end
			if(animationFrame == 3 and self.lastAnimationFrame ~= 3)then
				SetParticleEnabled(self.horseOneParticle, false)
				SetParticleEnabled(self.horseTwoParticle, false)
				SetParticleEnabled(self.chariotParticle, false)
			end		
		end
		if(anim ~= "fly" and anim ~= "fall" and anim ~= "jump")then
			SetParticleEnabled(self.horseOneParticle, false)
			SetParticleEnabled(self.horseTwoParticle, false)
			SetParticleEnabled(self.chariotParticle, false)
		end

		if(self.playFallingSound == true)then
			local volume = VehicleUtils.GetFallingSoundVolume(3)
			SFX.SetSoundVolume(self.fallingSound, volume)
		end

		anim, self.lastAnimationFrame = GetDeerAnimation()
		
		chariotAnim, chariotFrame = GetAnimationFrame(-1)
		
		deerX, deerY = GetDeerPosition(0);
		deer2X, deer2Y = GetDeerPosition(1);
		
		deerX = deerX - 5
		deerY = deerY - 5
		deer2X = deer2X - 5
		deer2Y = deer2Y - 5
		
		levelOffsetX, levelOffsetY = Level.GetOffset();
		levelOffset2X, levelOffset2Y = Level.GetOffset();
		
		rot = 0
		if(vehicleRotation ~= nil)then
			rot = math.rad(vehicleRotation)
		end
		
		startOffset = Vector.New(-Level.GetSpeed())
		desiredDir = RotateVector(startOffset, rot)
		finalDir = desiredDir - startOffset
		finalDir[2] = finalDir[2]*0.5
		
		SetRainbowVelocity(self.horseOneRainbowTrail, desiredDir[1], desiredDir[2])
		SetRainbowVelocity(self.horseTwoRainbowTrail, desiredDir[1], desiredDir[2])
		
		UpdateRainbowTrail(self.horseOneRainbowTrail, deerX - levelOffsetX, deerY, true)
		UpdateRainbowTrail(self.horseTwoRainbowTrail, deer2X - levelOffset2X, deer2Y, true)
		
		self.neighCounter = self.neighCounter + dt
		if(self.neighCounter > 2)then
			HorseNeigh()
			self.neighCounter = 0
		end
	end

	function Chariot:OnDraw()
		self.Base.OnDraw(self)
		
		self.headPos = Vector.New(GetVehiclePosition())
		worldPos = Vector.New(Level.GetOffset())
		
		vehicleRotation = GetVehicleRotation()
		wingRotation = math.rad(vehicleRotation) 
		
		chariotFrontWingPos = Vector.Clone(self.headPos)
		chariotBackWingPos = Vector.Clone(self.headPos)
		
		frontWingOffset = Vector.New(-23,2)
		frontWingOffset = RotateVector(frontWingOffset, -wingRotation)
		
		backWingOffset = Vector.New(-20,4)
		backWingOffset = RotateVector(backWingOffset, -wingRotation)
		
		chariotFrontWingPos = chariotFrontWingPos + frontWingOffset
		chariotBackWingPos = chariotBackWingPos + backWingOffset
		
		horseOnePos = Vector.New(0,0)
		horseTwoPos = Vector.New(0,0)
		
		horseOnePos[1], horseOnePos[2] = GetDeerPosition(0)
		horseTwoPos[1], horseTwoPos[2] = GetDeerPosition(1)
		
		local chariotParticlePos = self.headPos + Vector.New(-20,10) - worldPos
		SetParticlePosition(self.chariotParticle, chariotParticlePos[1], chariotParticlePos[2])
		
		horseOneRainbowPos = horseOnePos + Vector.New(10,10) - worldPos
		horseTwoRainbowPos = horseTwoPos + Vector.New(10,10) - worldPos
		
		horseOnePos = horseOnePos - worldPos
		horseTwoPos = horseTwoPos - worldPos
		
		SetParticlePosition(self.horseOneParticle, horseOnePos[1], horseOnePos[2])
		SetParticlePosition(self.horseTwoParticle, horseTwoPos[1], horseTwoPos[2])
		
		SetParticlePosition(self.horseOneRainbowParticle, horseOneRainbowPos[1], horseOneRainbowPos[2])
		SetParticlePosition(self.horseTwoRainbowParticle, horseTwoRainbowPos[1], horseTwoRainbowPos[2])
		
		DrawTexture(self.chariotWing, chariotFrontWingPos[1], chariotFrontWingPos[2], -vehicleRotation)
		DrawTexture(self.chariotWingBack, chariotBackWingPos[1], chariotBackWingPos[2], -vehicleRotation)
		
		DrawTexture(self.chariotWingBack, chariotBackWingPos[1], chariotBackWingPos[2], -vehicleRotation)
		
		DrawRainbowTrail(self.horseOneRainbowTrail)
		DrawRainbowTrail(self.horseTwoRainbowTrail)
		
		-- PUPPY STUFF!
		if(IsDogActive() == true)then
			dogPosition = Vector.New(GetDogPosition())
			dogRotation = GetDogRotation()
			dogScale = Vector.New(GetDogScale())
		
			if(dogScale[1] < 0)then
				dogScale[1] = -dogScale[1]
			end
			
			if(dogScale[2] < 0)then
				dogRotation = dogRotation + 180
				dogScale[1] = -dogScale[1]
				dogScale[2] = -dogScale[2]
			end
			
			dogOffset = Vector.New(0.0,0.0)
			dogOffset = RotateVector(dogOffset, math.rad(dogRotation))
			dogPosition = dogPosition + dogOffset
			DrawTexture(self.puppyWings, dogPosition[1], dogPosition[2], dogRotation, dogScale[1], dogScale[2])
		end
	end

	function Chariot.HitRoof()
		Log("HitRoof")
	end

	function Chariot.HitGround()
		Log("HitGround")
	end

	function Chariot:TouchUp()
		inputUp = true

	end

	function Chariot:TouchDown()
		if(self.playGroundSound == true)then
			Log("Stop Ground TouchDown")
			SFX.StopSound(self.groundSound or -1)
			self.playGroundSound = false
		end
		if(self.playFallingSound == true)then
			SFX.StopSound(self.fallingSound or -1,0.2)
			self.playFallingSound = false
		end

	end

	function Chariot:Diving()
		wingAnim, wingFrame = GetAnimationFrame(self.chariotWing)

		PlayAnimation(self.chariotWing,"flap_slow",wingFrame)
		PlayAnimation(self.chariotWingBack,"flap_slow",wingFrame)
		if(self.playGroundSound == true)then
			Log("Stop Ground Sound Diving")
			SFX.StopSound(self.groundSound or -1)
			self.playGroundSound = false
		end
		if(self.playFallingSound == false)then
			self.fallingSound = SFX.PlaySound("whale_flyLP",true)
			self.playFallingSound = true
		end
		--Log("Diving, animationFrame = "..animationFrame)
	end

	function Chariot:Flying()
		wingAnim, wingFrame = GetAnimationFrame(self.chariotWing)
		anim, animFrame = GetAnimationFrame(-1)
		if(anim == "chariot_spin")then
			PlayAnimation(-1,"chariot_slow")
		end
		PlayAnimation(self.chariotWing,"flap",wingFrame)
		PlayAnimation(self.chariotWingBack,"flap",wingFrame)
		if(self.playGroundSound == true)then
			Log("Stop Ground Sound Flying")
			SFX.StopSound(self.groundSound or -1)
			self.playGroundSound = false
		end
		if(self.playFallingSound == true)then
			SFX.StopSound(self.fallingSound or -1,0.2)
			self.playFallingSound = false
		end
		
		--Log("Flying animationFrame = "..animationFrame)	
	end

	function Chariot:Walking()
		wingAnim, wingFrame = GetAnimationFrame(self.chariotWing)
		SFX.PlaySound("chariot_land")
		PlayAnimation(self.chariotWing,"idle")
		PlayAnimation(self.chariotWingBack,"idle")
		if(self.playGroundSound == false)then
			self.groundSound = SFX.PlaySound("chariot_lp", true)
			self.playGroundSound = true
		end		
		if(self.playFallingSound == true)then
			SFX.StopSound(self.fallingSound or -1,0.2)
			self.playFallingSound = false
		end
		PlayAnimation(-1,"chariot_spin")

	end

	function Chariot:Explode()
		Log("Explode")

		SFX.StopSound(self.fallingSound or -1,0.2)
		self.playFallingSound = false
		SFX.StopSound(self.groundSound or -1)
		self.playGroundSound = false
		SetParticleEnabled(self.horseOneRainbowParticle, false)
		SetParticleEnabled(self.horseTwoRainbowParticle, false)
	end

	function Chariot:OnDestroy()
		local outroPlayed = VehicleUtils.PlayOutro(self)
		local clearSongOverride = not outroPlayed
		self.Base.OnDestroy(self, clearSongOverride)
	end

	function LogVec(name, vec)
		Log(name..": "..vec[1]..", "..vec[2])
	end

	function ChariotFlap()
		chariotFlap = math.random(3)

		if(chariotFlap == 1)then
			SFX.PlaySound("chariot_flap_01")
		elseif(chariotFlap == 2)then
			SFX.PlaySound("chariot_flap_02")
		elseif(chariotFlap == 3)then
			SFX.PlaySound("chariot_flap_03")	
		end

		chariotFlap = 0
	end

	function HorseNeigh() 
		neigh = math.random(10)

		if(neigh == 1)then
			SFX.PlaySound("chariot_vox_01")
		elseif(neigh == 2)then
			SFX.PlaySound("chariot_vox_02")
		elseif(neigh == 3)then
			SFX.PlaySound("chariot_vox_03")	
		elseif(neigh == 4)then
			SFX.PlaySound("chariot_vox_04")	
		end

		neigh = 0
	end

	function RotateVector(vec, rot)
		x = math.cos(rot) * vec[1] - math.sin(rot) * vec[2];
		y = math.sin(rot) * vec[1] + math.cos(rot) * vec[2];
		retVec = Vector.New(x, y)
		return retVec;
	end

	function RotateOffset(orig, pos, rot)
		offset = pos - orig
		offset = RotateVector(offset, rot)
		pos = orig + offset
		return pos
	end


	function Chariot.FlashToAnim_jumpLaunch(startFrame)
		Log("Flash JumpLaunch! Frame: "..startFrame)	
		PlayAnimation(Chariot.puppyWings, "jump", startFrame)

	end

	function Chariot.FlashToAnim_land(startFrame)
		Log("Flash Land! Frame: "..startFrame)
		PlayAnimation(Chariot.puppyWings, "land", startFrame)

	end

	function Chariot.FlashToAnim_run(startFrame)
		Log("Flash Run! Frame: "..startFrame)
		PlayAnimation(Chariot.puppyWings, "run", startFrame)
	end

	return Chariot
end

RegisterVehicle("Chariot", "Sled", ChariotBuilder.Build("Chariot", true, true, true))
