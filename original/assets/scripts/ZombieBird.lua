Log("ZombieBird Lua script started")

OverloadVehicleSounds()

local ZombieBird = {}
local birdBody
local birdSparks
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1
local birdParticles
local particleTimer = 0.1
local petbirdParticles
local petparticleTimer = 0.1

local fallingSound
local fallingSoundPlaying = false

function ZombieBird:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function ZombieBird.ComponentComplete()
	componentSound = math.random(3)

	if(componentSound == 1)then
		SFX.PlaySound("zombie_bird_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("zombie_bird_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("zombie_bird_form_3")
	end
	componentSound = 0
end

function ZombieBird:ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("zombie_bird_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function ZombieBird.PickupStart()
	OffsetPickupComponents(-5,2)
end


function ZombieBird:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	OverloadPickupSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	fallingSoundPlaying = false	

	Log("Init Particles!")
	birdParticles = CreateParticle("ZombieBird_BonesRain")
	SetParticleEnabled(birdParticles, false)
	petbirdParticles = CreateParticle("ZombieBird_BonesRain")
	SetParticleEnabled(petbirdParticles, false)
end

function ZombieBird.PickupSequenceUpdate(dt)
	Log("PickupSeuencUpsdat")
end

function ZombieBird:Ready(skipPickupSeq)
	Log("Ready")
	
	VehicleUtils.PlaySong(self, "music", "ready")

	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true
end

function ZombieBird:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end

	if(particleTimer > 0.0)then
		particleTimer = particleTimer - dt
	elseif(particleTimer < 0.0)then
		SetParticleEnabled(birdParticles, false)
		particleTimer = 0.0
	end	

	if(petparticleTimer > 0.0)then
		petparticleTimer = petparticleTimer - dt
	elseif(petparticleTimer < 0.0)then
		SetParticleEnabled(petbirdParticles, false)
		petparticleTimer = 0.0
	end	
end

function ZombieBird:OnDraw()
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
		SetParticlePosition(petbirdParticles, finalpetParticlePos[1], finalpetParticlePos[2])		
	
	end

	birdParticlePos = headPos + Vector.New(-40.0, -5.0)
	finalBirdParticlePos = birdParticlePos - worldPos
	SetParticlePosition(birdParticles, finalBirdParticlePos[1], finalBirdParticlePos[2])
end

function ZombieBird.HitRoof()
	Log("HitRoof")
end

function ZombieBird.HitGround()
	PlayAnimation(birdBody,"hitGround")
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("zombie_bird_land")
	ground = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("zombie_bird_slideLP",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function ZombieBird.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("zombie_bird_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("zombie_bird_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("zombie_bird_vox_3")
	end		
end

function ZombieBird.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function ZombieBird.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function ZombieBird.TouchDown()
	Log("TouchDown")
end

function ZombieBird.Jump()
	componentSound = math.random(3)
	Log("randomFlap = "..componentSound)

	if(ground > 0)then
		PlayAnimation(birdBody,"offGround")
		
		ground = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("zombie_bird_flap_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("zombie_bird_flap_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("zombie_bird_flap_3")
	elseif(componentSound == 4)then		
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false

	particleTimer = 0.3
	SetParticleEnabled(birdParticles, true)		
end

function ZombieBird.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("zombie_bird_explode")
	playBirdGrind = -1
end

function ZombieBird:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function ZombieBird.FlashToAnim_vehicleNoFlap()

end

function ZombieBird.FlashToAnim_Flap()
	dogFlap = math.random(3)
	petparticleTimer = 0.3
	SetParticleEnabled(petbirdParticles, true)	
end

RegisterVehicle("ZombieBird", "Bird", ZombieBird);