Log("CnyPig Lua script started")

OverloadVehicleSounds()

local CnyPig = {}
local birdBody
local birdSparks
local headPos
local eyePos
local eyeGround = -1
local bodyRotation = 0.0
local birdGrind
local playBirdGrind = -1
local coinEffect;
local coinTimer = 0.3;
local petCoinEffect;
local petCoinTimer = 0.3;

local fallingSound
local fallingSoundPlaying = false


function CnyPig.ComponentComplete()

end

function CnyPig:ConstructionComplete()
	rotRadEye = math.rad(bodyRotation - 90.0)
	headPos = Vector.New(GetPlayerPosition())

	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function CnyPig.PickupStart()
	OffsetPickupComponents(-5,2)
end


function CnyPig:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	coinEffect = CreateParticle("CNY_PIG")
	SetParticleEnabled(coinEffect, false)
	petCoinEffect = CreateParticle("CNY_PIG")
	SetParticleEnabled(petCoinEffect, false)	
	--SetBirdOffset(9,2)
	OverloadVehicleSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	Log("Init Particles!")
	fallingSoundPlaying = false
end

function CnyPig:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function CnyPig.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function CnyPig:Ready(skipPickupSeq)
	Log("Ready")
	VehicleUtils.PlaySong(self, "music", "ready")

	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true
end

function CnyPig:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(coinTimer > 0.0)then
		coinTimer = coinTimer - dt
	elseif(coinTimer < 0.0 and componentSound == 1)then
		SFX.PlaySound("pig_coin_1")
		coinTimer = 0.3
	elseif(coinTimer < 0.0 and componentSound == 2)then
		SFX.PlaySound("pig_coin_2")
		coinTimer = 0.3
	elseif(coinTimer < 0.0 and componentSound == 3)then
		SFX.PlaySound("pig_coin_3")
		coinTimer = 0.3
	end
	if(petCoinTimer > 0.0)then
		petCoinTimer = petCoinTimer - dt
	elseif(petCoinTimer < 0.0 and componentSound == 1)then
		SFX.PlaySound("pig_coin_1")
		petCoinTimer = 0.3
	elseif(petCoinTimer < 0.0 and componentSound == 2)then
		SFX.PlaySound("pig_coin_2")
		petCoinTimer = 0.3
	elseif(petCoinTimer < 0.0 and componentSound == 3)then
		SFX.PlaySound("pig_coin_3")
		petCoinTimer = 0.3
	end
	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end


end

function CnyPig:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	sparksPos = Vector.Clone(headPos) 
	
	if(eyeGround == 1)then
		DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end

	worldPos = Vector.New(Level.GetOffset())

	nosePos = headPos + Vector.New(-25.0, -5.0)	
	finalNosePos = nosePos - worldPos
	SetParticlePosition(coinEffect, finalNosePos[1], finalNosePos[2])

	if(IsDogActive() == true)then
		petPosition = Vector.New(GetDogPosition())
		petParticlePos = petPosition + Vector.New(-14.0, -5.0)
	
		finalpetParticlePos = petParticlePos - worldPos
		SetParticlePosition(petCoinEffect, finalpetParticlePos[1], finalpetParticlePos[2])	
	end

end

function CnyPig.HitRoof()
	Log("HitRoof")
end

function CnyPig.HitGround()
	PlayAnimation(birdBody,"hitGround")
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("bird_land")
	eyeGround = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("bird_slideLP",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function CnyPig.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("flying_pig_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("flying_pig_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("flying_pig_vox_3")
	end		
end

function CnyPig.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function CnyPig.TouchUp()

	SetParticleEnabled(coinEffect, false)		

	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function CnyPig.TouchDown()
	Log("TouchDown")
end

function CnyPig.Jump()
	componentSound = math.random(3)
	Log("randomFlap = "..componentSound)
	coinTimer = 0.35

	if(eyeGround > 0)then
		PlayAnimation(birdBody,"offGround")
		
		eyeGround = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("bird_flap_1")
		SetParticleEnabled(coinEffect, true)
	elseif(componentSound == 2)then
		SFX.PlaySound("bird_flap_2")
		SetParticleEnabled(coinEffect, true)		
	elseif(componentSound == 3)then
		SFX.PlaySound("bird_flap_1")	
		SetParticleEnabled(coinEffect, true)	
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
end

function CnyPig.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.PlaySound("mech_explode")
	SFX.StopSound(birdGrind or -1)
	playBirdGrind = -1
end

function CnyPig:OnDestroy()
	Log("OnDestroy")
	
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function CnyPig.FlashToAnim_vehicleNoFlap()

end

function CnyPig.FlashToAnim_Flap()
	petCoinTimer = 0.35
	SetParticleEnabled(petCoinEffect, true)	
	dogFlap = math.random(3)
end

RegisterVehicle("CnyPig", "Bird", CnyPig);