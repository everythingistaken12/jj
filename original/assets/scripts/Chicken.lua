Log("Chicken Lua script started")

OverloadVehicleSounds()

local Chicken = {}
local birdBody
local birdSparks
local headPos
local eyePos
local eyeGround = -1
local bodyRotation = 0.0
local birdGrind
local playBirdGrind = -1
local eggPosition
local petEggPosition

local fallingSound
local fallingSoundPlaying = false

function Chicken:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Chicken.ComponentComplete()

end

function Chicken:ConstructionComplete()
	rotRadEye = math.rad(bodyRotation - 90.0)
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("chicken_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function Chicken.PickupStart()
	OffsetPickupComponents(-5,2)
end


function Chicken:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	--SetBirdOffset(9,2)
	OverloadVehicleSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	Log("Init Particles!")
	fallingSoundPlaying = false
end

function Chicken.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function Chicken:Ready(skipPickupSeq)
	Log("Ready")
	
	VehicleUtils.PlaySong(self, "music", "ready")

	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true
end

function Chicken:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end


end

function Chicken:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	sparksPos = Vector.Clone(headPos) 
	
	if(eyeGround == 1)then
		DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end

	worldPos = Vector.New(Level.GetOffset())

	nosePos = headPos + Vector.New(-25.0, -5.0)	
	finalNosePos = nosePos - worldPos
	eggPosition = finalNosePos

	if(IsDogActive() == true)then
		petPosition = Vector.New(GetDogPosition())
		petParticlePos = petPosition + Vector.New(-14.0, -5.0)
	
		finalpetParticlePos = petParticlePos - worldPos
		petEggPosition = finalpetParticlePos
	end

end

function Chicken.HitRoof()
	Log("HitRoof")
end

function Chicken.HitGround()
	PlayAnimation(birdBody,"hitGround")
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("chicken_land")
	eyeGround = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("bird_slideLP",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function Chicken.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("chicken_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("chicken_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("chicken_vox_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("chicken_vox_4")
	elseif(componentSound == 5)then
		SFX.PlaySound("chicken_vox_5")
	end		
end

function Chicken.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function Chicken.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function Chicken.TouchDown()
	Log("TouchDown")
end

function Chicken.Jump()
	componentSound = math.random(3)
	Log("randomFlap = "..componentSound)

	if(eyeGround > 0)then
		PlayAnimation(birdBody,"offGround")
		
		eyeGround = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("bird_flap_1")
		SFX.PlaySound("chicken_egg_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("bird_flap_2")
		SFX.PlaySound("chicken_egg_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("bird_flap_3")	
		SFX.PlaySound("chicken_egg_3")
	end
	if(eggPosition ~= nil)then
		ThrowEgg(6, eggPosition[1], eggPosition[2]);
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
end

function Chicken.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.PlaySound("chicken_explode")
	SFX.StopSound(birdGrind or -1)
	playBirdGrind = -1
end

function Chicken:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function Chicken.FlashToAnim_vehicleNoFlap()

end

function Chicken.FlashToAnim_Flap()
	if(petEggPosition ~= nil)then
		ThrowEgg(4, petEggPosition[1], petEggPosition[2]);
	end
	dogFlap = math.random(3)
	SFX.PlaySound("chicken_egg_"..dogFlap)
end

RegisterVehicle("Chicken", "Bird", Chicken);
