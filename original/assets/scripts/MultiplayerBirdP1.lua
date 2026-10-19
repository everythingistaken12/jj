Log("MultiplayerBirdP1 Lua script started")

OverloadVehicleSounds()

local MultiplayerBirdP1 = {}
local birdBody
local birdSparks
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1
local featherParticles
local featherTimer = 0.1
local petFeatherParticles
local petFeatherTimer = 0.1

local fallingSound
local fallingSoundPlaying = false

function MultiplayerBirdP1.ComponentComplete()

end

function MultiplayerBirdP1.ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("vehicle_form_complete")
end

function MultiplayerBirdP1.PickupStart()
	OffsetPickupComponents(-5,2)
end


function MultiplayerBirdP1:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	fallingSoundPlaying = false	

	Log("Init Particles!")
	featherParticles = CreateParticle("Money")
	SetParticleEnabled(featherParticles, false)
	petFeatherParticles = CreateParticle("Money")
	SetParticleEnabled(petFeatherParticles, false)
end

function MultiplayerBirdP1.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function MultiplayerBirdP1.Ready(skipPickupSeq)
	Log("Ready")
	
	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true
end

function MultiplayerBirdP1:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end

	if(featherTimer > 0.0)then
		featherTimer = featherTimer - dt
	elseif(featherTimer < 0.0)then
		SetParticleEnabled(featherParticles, false)
		featherTimer = 0.0
	end	

	if(petFeatherTimer > 0.0)then
		petFeatherTimer = petFeatherTimer - dt
	elseif(petFeatherTimer < 0.0)then
		SetParticleEnabled(petFeatherParticles, false)
		petFeatherTimer = 0.0
	end	
end

function MultiplayerBirdP1:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	sparksPos = Vector.Clone(headPos) 
	
	if(ground == 1)then
		DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end

	worldPos = Vector.New(Level.GetOffset())

	if(IsDogActive() == true)then
		petPosition = Vector.New(GetDogPosition())
		petParticlePos = petPosition + Vector.New(-14.0, -5.0)

		finalpetParticlePos = petParticlePos - worldPos
		SetParticlePosition(petFeatherParticles, finalpetParticlePos[1], finalpetParticlePos[2])		
	
	end

	featherParticlePos = headPos + Vector.New(-30.0, -5.0)
	finalFeatherParticlePos = featherParticlePos - worldPos
	SetParticlePosition(featherParticles, finalFeatherParticlePos[1], finalFeatherParticlePos[2])
end

function MultiplayerBirdP1.HitRoof()
	Log("HitRoof")
end

function MultiplayerBirdP1.HitGround()
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

function MultiplayerBirdP1.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("bird_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("bird_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("bird_vox_3")
	end		
end

function MultiplayerBirdP1.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function MultiplayerBirdP1.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function MultiplayerBirdP1.TouchDown()
	Log("TouchDown")
	componentSound = math.random(3)
	Log("randomFlap = "..componentSound)

	if(ground > 0)then
		PlayAnimation(birdBody,"offGround")
		
		ground = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("bird_flap_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("bird_flap_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("bird_flap_3")
	elseif(componentSound == 4)then		
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false

	featherTimer = 0.3
	SetParticleEnabled(featherParticles, true)		
end

function MultiplayerBirdP1.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("mech_explode")
	playBirdGrind = -1
end

function MultiplayerBirdP1:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	SFX.StopSound(birdGrind or -1)

	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function MultiplayerBirdP1.FlashToAnim_vehicleNoFlap()

end

function MultiplayerBirdP1.FlashToAnim_Flap()
	dogFlap = math.random(3)
	petFeatherTimer = 0.3
	SetParticleEnabled(petFeatherParticles, true)	
end

RegisterVehicle("MultiplayerBirdP1", "Bird", MultiplayerBirdP1);
