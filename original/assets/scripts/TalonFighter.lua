Log("TalonFighter Lua script started")

OverloadVehicleSounds()

local TalonFighter = {}
local birdBody
local birdSparks
local wheelie = false
local wheelieDust
local wheelieDustCounter = 0.0
local groundSound = -1
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1
local birdBoost
local birdBoostCounter = 0.0
local wobbleYOffsetCounter = 0.0
local shadowTex

local petBoost
local petBoostCounter = 0.0

local fallingSound
local flyingSound
local fallingSoundPlaying = false
local flyingSoundPlaying = false
local fallingStartYVelocity = -3
local flyingEndYVelocity = -1
local risingStopYVelocity = 1
local blendFactorFlyToDive = -1
local blendFactorDiveToFly = 0.5
local flyVolume = 0

function TalonFighter.GetTextureList()
	return "textures/Characters/Vehicles/Bird/TalonFighter/boost.tex, textures/Characters/Vehicles/Hog/HoverHog/effect_skidsmoke.tex"
end

function TalonFighter.ComponentComplete()

end

function TalonFighter.ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("hm_talon_fighter_form_complete")
end

function TalonFighter.PickupStart()
	OffsetPickupComponents(-5,2)
end


function TalonFighter:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	SetBirdBodyHorizontalOffset(35)
	SetBirdBeakHorizontalOffset(29)
	SetBirdOffset(0, 5)
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	birdBoost = LoadTexture("textures/Characters/Vehicles/Bird/TalonFighter/boost.xml", 10)
	petBoost = LoadTexture("textures/Characters/Vehicles/Bird/TalonFighter/boost.xml", 10)
	wheelieDust = LoadTexture("textures/Characters/Vehicles/Bird/TalonFighter/effect_skidsmoke.xml", 10)
	fallingSoundPlaying = false
	flyingSoundPlaying = false

	self:SetDrawShadow(false)
	
	shadowTex = LoadTexture("textures/Effects/effect_shadow.xml",9)
	self.shadowSize = Vector.New(3.0,1.0)
	SetCollisionOffset(0.0, 10.0)
end

function TalonFighter.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function TalonFighter.Ready(skipPickupSeq)
	Log("Ready")
	
	fallingSound = SFX.PlaySound("hm_talon_fighter_fall",true)
	fallingSoundPlaying = true
end

function TalonFighter:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local vel = VehicleUtils.GetFallingVelocity()
		if vel < fallingStartYVelocity then
			SFX.SetSoundVolume(fallingSound, 1)
		else
			SFX.SetSoundVolume(fallingSound, 0)
		end
	end

	if flyingSoundPlaying == true then
		local vel = VehicleUtils.GetFallingVelocity()
		local threshold = fallingStartYVelocity
		if vel < threshold then
			local delta = (threshold - vel) * blendFactorFlyToDive
			flyVolume = flyVolume - delta
		elseif vel > threshold and vel < risingStopYVelocity then
			local delta = (vel - threshold) * blendFactorDiveToFly
			flyVolume = flyVolume + delta
		else
			flyVolume = 1
		end
		flyVolume = math.max(0, math.min(1, flyVolume))
		SFX.SetSoundVolume(flyingSound, flyVolume)
	end

	if(birdBoostCounter > 0.0)then
		birdBoostCounter = birdBoostCounter - dt
	end

	if(wheelieDustCounter > 0.0)then
		wheelieDustCounter = wheelieDustCounter - dt
	end

	if(petBoostCounter > 0.0)then
		petBoostCounter = petBoostCounter - dt
	end	
	
	if(wobbleYOffsetCounter > 0.0)then
		wobbleYOffsetCounter = wobbleYOffsetCounter - dt
	end

		

	if(wheelie == true and frame == 6)then
		if(groundSound == -1)then
			Log("Play Hover Engine Initially")
			--groundSound = SFX.PlaySound("hover_engine_lp",true)
		end
	end

end

function TalonFighter:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition()) + Vector.New(0.0, 5.0)
	sparksPos = Vector.Clone(headPos)
	worldPos = Vector.New(Level.GetOffset())
	
	wobbleYOffset = (math.random() * 1) - 0.5

	if(ground == 1 and wobbleYOffsetCounter <= 0.0)then
		SetBirdOffset(0, 5 + wobbleYOffset)
		wobbleYOffsetCounter = math.random() * 0.25
	elseif(ground == -1)then
		SetBirdOffset(0, 5)
	end

	if(IsDogActive() == true)then	
		petPosition = Vector.New(GetDogPosition())
		petBoostPos = petPosition + Vector.New(-25.0, 0.0)
	end
	
	if(ground == 1)then
		--DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end

	if(birdBoostCounter > 0.0)then
		DrawTexture(birdBoost, sparksPos[1] -66, sparksPos[2] - 5)
	end

	if(ground == 1)then
		DrawTexture(wheelieDust, headPos[1] - 75, headPos[2]  + 5)
	end

	if(petBoostCounter > 0.0)then
		DrawTexture(petBoost, petBoostPos[1] + 10, petBoostPos[2])
	end

	playerPos = Vector.New(GetPlayerPosition())
	shadowPos = playerPos + Vector.New(-10.0,0.0)
	playerY = (137 + playerPos[2])
	playerX = playerY / 800
	playerY = playerY / 400
	DrawTexture(shadowTex, shadowPos[1], -137, 0, self.shadowSize[1] - (playerY * 2), self.shadowSize[2] - playerY, 0.5)	

end

function TalonFighter.HitRoof()
	Log("HitRoof")
end

function TalonFighter.HitGround()
	PlayAnimation(birdBody,"hitGround")
	--PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("hm_talon_fighter_land")
	ground = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("hm_talon_fighter_grind_lp",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	flyingSoundPlaying = false;
	SFX.StopSound(flyingSound or -1)
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	wheelie = true

	if(groundSound == -1)then
		--groundSound = SFX.PlaySound("hover_engine_lp",true)
	end

	Log("HitGround")
end

function TalonFighter.CloseToCoins()
	--PlayAnimation(birdBody,"eat")
end

function TalonFighter.FarFromCoins()
	--PlayAnimation(birdBody,"eatClose")
end

function TalonFighter.TouchUp()
	--Log("TOUCHUP")
end

function TalonFighter.TouchDown()
	--Log("TOUCHDOWN")
end

function TalonFighter.Jump()
	Log("JUMP")
	componentSound = math.random(4)
	Log("randomFlap = "..componentSound)

	if(ground > 0)then
		PlayAnimation(birdBody,"offGround")
		ground = -1
	end

	if(componentSound == 1)then
		SFX.PlaySound("hm_talon_fighter_flap_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("hm_talon_fighter_flap_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("hm_talon_fighter_flap_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("hm_talon_fighter_flap_1")
	end
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
	end
	playBirdGrind = -1

	PlayAnimation(birdBoost,"boost")

	birdBoostCounter = 0.3

	fallingSound = SFX.PlaySound("hm_talon_fighter_fall",true)
	fallingSoundPlaying = true

	flyingSound = SFX.PlaySound("hm_talon_fighter_fly_lp",true)
	flyingSoundPlaying = true
	
end

function TalonFighter.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	flyingSoundPlaying = false
	SFX.StopSound(flyingSound or -1)
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("hm_talon_fighter_explode")
	playBirdGrind = -1
end

function TalonFighter:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	SFX.StopSound(flyingSound or -1)
	SFX.StopSound(birdGrind or -1)
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function TalonFighter.FlashToAnim_vehicleNoFlap()

end

function TalonFighter.FlashToAnim_Flap()
	dogFlap = math.random(3)

	PlayAnimation(petBoost,"boost")

	componentSound = math.random(4)

	if(componentSound == 1)then
		SFX.PlaySound("hm_talon_fighter_flame_01")
	elseif(componentSound == 2)then
		SFX.PlaySound("hm_talon_fighter_flame_02")
	elseif(componentSound == 3)then
		SFX.PlaySound("hm_talon_fighter_flame_03")
	elseif(componentSound == 4)then
		SFX.PlaySound("hm_talon_fighter_flame_04")
	end

	petBoostCounter = 0.3	
end

RegisterVehicle("TalonFighter", "Bird", TalonFighter);