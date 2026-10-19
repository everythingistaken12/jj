Log("MSBird Lua script started")

OverloadVehicleSounds()

local MSBird = {}
local birdBody
local birdSparks
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1
local birdBoost
local birdBoostCounter = 0.0

local petBoost
local petBoostCounter = 0.0

local fallingSound
local fallingSoundPlaying = false

function MSBird.GetTextureList()
	return "textures/Characters/Vehicles/Bird/MSBird/boost.tex"
end

function MSBird.ComponentComplete()

end

function MSBird.ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("ms_vehicle_form_complete")
end

function MSBird.PickupStart()
	OffsetPickupComponents(-5,2)
end


function MSBird:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	birdBoost = LoadTexture("textures/Characters/Vehicles/Bird/MSBird/boost.xml", 10)
	petBoost = LoadTexture("textures/Characters/Vehicles/Bird/MSBird/boost.xml", 10)
	fallingSoundPlaying = false	
end

function MSBird.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function MSBird.Ready(skipPickupSeq)
	Log("Ready")
	
	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true
end

function MSBird:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end

	if(birdBoostCounter > 0.0)then
		birdBoostCounter = birdBoostCounter - dt
	end

	if(petBoostCounter > 0.0)then
		petBoostCounter = petBoostCounter - dt
	end		
end

function MSBird:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	sparksPos = Vector.Clone(headPos)
	worldPos = Vector.New(Level.GetOffset())

	if(IsDogActive() == true)then	
		petPosition = Vector.New(GetDogPosition())
		petBoostPos = petPosition + Vector.New(-25.0, 0.0)
	end
	
	if(ground == 1)then
		DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end

	if(birdBoostCounter > 0.0)then
		DrawTexture(birdBoost, sparksPos[1] -45, sparksPos[2] - 7)
	end

	if(petBoostCounter > 0.0)then
		DrawTexture(petBoost, petBoostPos[1], petBoostPos[2])
	end	

end

function MSBird.HitRoof()
	Log("HitRoof")
end

function MSBird.HitGround()
	PlayAnimation(birdBody,"hitGround")
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("medic_bird_land")
	ground = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("bird_slideLP",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function MSBird.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("ms_bird_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("ms_bird_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("ms_bird_vox_3")
	end		
end

function MSBird.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function MSBird.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function MSBird.TouchDown()
	Log("TouchDown")
end

function MSBird.Jump()
	componentSound = math.random(4)
	Log("randomFlap = "..componentSound)

	if(ground > 0)then
		PlayAnimation(birdBody,"offGround")
		
		ground = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("ms_bird_flap_1")
		SFX.PlaySound("ms_bird_flame_01")
	elseif(componentSound == 2)then
		SFX.PlaySound("ms_bird_flap_2")
		SFX.PlaySound("ms_bird_flame_02")
	elseif(componentSound == 3)then
		SFX.PlaySound("ms_bird_flap_3")
		SFX.PlaySound("ms_bird_flame_03")
	elseif(componentSound == 4)then
		SFX.PlaySound("ms_bird_flap_1")
		SFX.PlaySound("ms_bird_flame_04")
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false

	PlayAnimation(birdBoost,"boost")

	birdBoostCounter = 0.3
end

function MSBird.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("ms_vehicle_explode")
	playBirdGrind = -1
end

function MSBird:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function MSBird.FlashToAnim_vehicleNoFlap()

end

function MSBird.FlashToAnim_Flap()
	dogFlap = math.random(3)

	PlayAnimation(petBoost,"boost")

	componentSound = math.random(4)

	if(componentSound == 1)then
		SFX.PlaySound("ms_bird_flame_01")
	elseif(componentSound == 2)then
		SFX.PlaySound("ms_bird_flame_02")
	elseif(componentSound == 3)then
		SFX.PlaySound("ms_bird_flame_03")
	elseif(componentSound == 4)then
		SFX.PlaySound("ms_bird_flame_04")
	end

	petBoostCounter = 0.3	
end

RegisterVehicle("MSBird", "Bird", MSBird);
