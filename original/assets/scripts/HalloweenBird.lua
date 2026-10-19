Log("HalloweenBird Lua script started")

OverloadVehicleSounds()

local HalloweenBird = {}
local birdBody
local birdSparks
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1
local bandageParticles
local particleTimer = 0.1
local petbandageParticles
local petparticleTimer = 0.1

local fallingSound
local fallingSoundPlaying = false

function HalloweenBird:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function HalloweenBird.ComponentComplete()

end

function HalloweenBird:ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("haunted_bird_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function HalloweenBird.PickupStart()
	OffsetPickupComponents(-5,2)
end


function HalloweenBird:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	fallingSoundPlaying = false	

	Log("Init Particles!")
	bandageParticles = CreateParticle("goldFeathersFlap")
	SetParticleEnabled(bandageParticles, false)
	petbandageParticles = CreateParticle("turkeyFeathersFlap")
	SetParticleEnabled(petbandageParticles, false)
end

function HalloweenBird.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function HalloweenBird:Ready(skipPickupSeq)
	Log("Ready")
	
	VehicleUtils.PlaySong(self, "music", "ready")

	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true
end

function HalloweenBird:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end

	if(particleTimer > 0.0)then
		particleTimer = particleTimer - dt
	elseif(particleTimer < 0.0)then
		SetParticleEnabled(bandageParticles, false)
		particleTimer = 0.0
	end	

	if(petparticleTimer > 0.0)then
		petparticleTimer = petparticleTimer - dt
	elseif(petparticleTimer < 0.0)then
		SetParticleEnabled(petbandageParticles, false)
		petparticleTimer = 0.0
	end	
end

function HalloweenBird:OnDraw()
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
		SetParticlePosition(petbandageParticles, finalpetParticlePos[1], finalpetParticlePos[2])		
	
	end

	bandageParticlePos = headPos + Vector.New(-40.0, -5.0)
	finalBandageParticlePos = bandageParticlePos - worldPos
	SetParticlePosition(bandageParticles, finalBandageParticlePos[1], finalBandageParticlePos[2])
end

function HalloweenBird.HitRoof()
	Log("HitRoof")
end

function HalloweenBird.HitGround()
	PlayAnimation(birdBody,"hitGround")
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("chicken_land")
	ground = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("bird_slideLP",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function HalloweenBird.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("haunted_bird_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("haunted_bird_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("haunted_bird_vox_3")
	end		
end

function HalloweenBird.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function HalloweenBird.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function HalloweenBird.TouchDown()
	Log("TouchDown")
end

function HalloweenBird.Jump()
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

	particleTimer = 0.3
	SetParticleEnabled(bandageParticles, true)		
end

function HalloweenBird.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("haunted_bird_explode")
	playBirdGrind = -1
end

function HalloweenBird:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function HalloweenBird.FlashToAnim_vehicleNoFlap()

end

function HalloweenBird.FlashToAnim_Flap()
	dogFlap = math.random(3)
	petparticleTimer = 0.3
	SetParticleEnabled(petbandageParticles, true)	
end

RegisterVehicle("HalloweenBird", "Bird", HalloweenBird);
