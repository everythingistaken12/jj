Log("GingerBreadSleigh Lua script started")

function MakeGingerbreadSleigh(skin)
	local GingerbreadSleigh = {}

	GingerbreadSleigh.Sounds = {}
	GingerbreadSleigh.Sounds.FootStep = nil
	GingerbreadSleigh.Sounds.Sliding = Sound.new("sled_slide_lp", true, 1.0)
	GingerbreadSleigh.Sounds.Flying = Sound.new("sleigh_gingerbread_fly_lp", true, 1.0)
	GingerbreadSleigh.Sounds.AmbientLoop = nil --Sound.new("sleigh_gingerbread_fly_lp", true, 1.0)
	GingerbreadSleigh.Sounds.AfterburnerLoop = Sound.new("sleigh_gingerbread_afterburner_lp", true, 1.0)
	GingerbreadSleigh.Sounds.SoundLand = Sound.new("chariot_land", false, 1.0)

	GingerbreadSleigh.Sounds.FootStepCaveLeft = { "reindeer_step_dirt_left_1", "reindeer_step_dirt_left_2" }
	GingerbreadSleigh.Sounds.FootStepCaveRight = { "reindeer_step_dirt_right_1", "reindeer_step_dirt_right_2" }

	GingerbreadSleigh.Sounds.FootStepLeft = { 
		"reindeer_step_metal_left_1",
		"reindeer_step_metal_left_2",
		"reindeer_step_metal_left_3",
		"reindeer_step_metal_left_4"
	}

	GingerbreadSleigh.Sounds.FootStepRight = { 
		"reindeer_step_metal_right_1",
		"reindeer_step_metal_right_2",
		"reindeer_step_metal_right_3",
		"reindeer_step_metal_right_4"
	}

	GingerbreadSleigh.constructionComplete = false

	function GingerbreadSleigh.GetTextureList()
		return "textures/Effects/Jetpack/rainbowSparkle.tex"..
			"|textures/Characters/Vehicles/sled/"..skin.."/flame.tex"..
			"|textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetTransition.tex"..
			"|textures/Characters/RobotDog/Vehicles/"..skin.."/sledAntlers.tex"
	end

	function GingerbreadSleigh:BannerComplete()
		VehicleUtils.PlaySong(self, "music", "banner_complete")
	end

	function GingerbreadSleigh.PickupStart()
		-- OffsetPickupComponents(0, 7)
		-- OffsetChildPickupComponents(5,0)
		-- SetFirstComponentToFront(false)
		SetChildComponentToFront(false)
	end

	function GingerbreadSleigh:ComponentComplete(vehicleType)
		if (self.componentCompleteSfx ~= nil) then
			local componentSound = math.random(#self.componentCompleteSfx)
			SFX.PlaySound(self.componentCompleteSfx[componentSound])
		end
		UpdateVehicle()
	end

	function GingerbreadSleigh:ConstructionComplete(vehicleType)
		Log("GingerbreadSleigh:ConstructionComplete: "..tostring(vehicleType))
		if (self.constructionComplete == false)then
			self.constructionComplete = true
			-- OffsetVehiclePosition(19, 9)
		end

		-- SetBarryOffset(15, 0)
		UpdateVehicle()

		if (self.constructionCompleteSfx ~= nil) then
			SFX.PlaySound(self.constructionCompleteSfx)
		end
		VehicleUtils.PlaySong(self, "music", "construction_complete")
	end

	function GingerbreadSleigh:OnInit(info)
		self.Base.OnInit(self, info)

		self.componentCompleteSfx = self:GetSkinArrayAttribute("componentCompleteSfx")
		self.constructionCompleteSfx = self:GetSkinAttribute("constructionCompleteSfx")
		if (self.componentCompleteSfx ~= nil or self.constructionCompleteSfx ~= nil) then
			OverloadPickupSounds(true)
		end
		
		-- SetDrawOffset(5,-5)
		-- SetDeerOffset(2,0)
		SetSleighOffset(1, 10)
		SetDrawBody(true)
		SetSleighFlameDelay(0.1)

		math.randomseed(os.time())
		math.random()
		math.random()
		math.random()
	end

	function GingerbreadSleigh.PickupSequenceUpdate(dt)
	end

	function GingerbreadSleigh:Ready(skipPickupSeq)
		Log("Ready")
		VehicleUtils.PlaySong(self, "music", "ready")
		
		if (skipPickupSeq) then
			-- SetBarryOffset(-16,5)
		end
	end

	function GingerbreadSleigh:OnUpdate(dt)
		self.Base.OnUpdate(self, dt)
	end

	function GingerbreadSleigh:OnDraw()
		self.Base.OnDraw(self)
	end

	function GingerbreadSleigh.HitRoof()
		Log("HitRoof")
	end

	function GingerbreadSleigh.HitGround()
		Log("HitGround")
	end

	function GingerbreadSleigh:TouchUp()
		inputUp = true
	end

	function GingerbreadSleigh:TouchDown()
	end

	function GingerbreadSleigh:Diving()
	end

	function GingerbreadSleigh:Flying()
	end

	function GingerbreadSleigh:Walking()
		self.Sounds.SoundLand:Play()
		PlayAnimation(-1, "chariot_spin")
	end

	function GingerbreadSleigh:Explode()
		Log("Explode")
	end

	function GingerbreadSleigh:OnDestroy()
		self.Sounds.Sliding:Stop(0.05)
		self.Sounds.Flying:Stop(0.05)
		if self.Sounds.AmbientLoop ~= nil then
			self.Sounds.AmbientLoop:Stop(0.05)
		end

		local outroPlayed = VehicleUtils.PlayOutro(self)
		local clearSongOverride = not outroPlayed
		self.Base.OnDestroy(self, clearSongOverride)
	end

	function GingerbreadSleigh:PlaySound(sound)
		local sound = Sound.new(sound)
		sound:Play()
		return sound
	end

	function GingerbreadSleigh:PlayRandomSound(sounds)
		return self:PlaySound(sounds[math.random(1, #sounds)])
	end

	-- called from c++
	function GingerbreadSleigh:PlayFootstepSfx(chunkHash, frameIdx)
		local LEFT_FOOT_FRAME = 3
		if chunkHash == "cave.xml" then
			if frameIdx == LEFT_FOOT_FRAME then
				self.Sounds.FootStep = self:PlayRandomSound(self.Sounds.FootStepCaveLeft)
			else
				self.Sounds.FootStep = self:PlayRandomSound(self.Sounds.FootStepCaveRight)
			end
		else
			if frameIdx == LEFT_FOOT_FRAME then
				self.Sounds.FootStep = self:PlayRandomSound(self.Sounds.FootStepLeft)
			else
				self.Sounds.FootStep = self:PlayRandomSound(self.Sounds.FootStepRight)
			end
		end

		return true
	end

	-- called from c++
	function GingerbreadSleigh:PlayAmbientSfx()
		if self.Sounds.AmbientLoop ~= nil then
			self.Sounds.AmbientLoop:Play()
		end

		return true
	end

	-- called from c++
	function GingerbreadSleigh:UpdateSliding(isOnGround)
		if (isOnGround) then
			self.Sounds.Sliding:Play()
			self.Sounds.Flying:Stop(0.05)
		else
			self.Sounds.Sliding:Stop(0.05)
			self.Sounds.Flying:Play()
		end

		return true
	end

	function GingerbreadSleigh:PlayAfterburnerLoop()
		self.Sounds.AfterburnerLoop:Play()

		return true
	end

	function GingerbreadSleigh:StopAfterburnerLoop()
		self.Sounds.AfterburnerLoop:Stop(0.05)

		return true
	end

	return GingerbreadSleigh
end

RegisterVehicle("GingerBreadSleigh", "Sled", MakeGingerbreadSleigh("GingerBreadSleigh"))