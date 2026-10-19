Log("Micro Lua script started")

OverloadVehicleSounds()

local Micro = {}
local microEye
local microTail
local microSparks
local headPos
local eyePos
local eyeGround = -1
local bubbleParticles
local bubbleTimer = 0.1
local bodyRotation = 0.0
local microGrind
local playMicroGrind = -1
local microBubbles
local petBubbles
local petBubbleTimer = 0.1

local fallingSound
local fallingSoundPlaying = false

function Micro.GetTextureList()
	return "textures/Characters/Vehicles/Bird/Micro/microEye.tex|textures/Characters/Vehicles/Bird/Micro/micro_tail.tex|Particles/bubble.tex"
end

function Micro:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Micro.ComponentComplete()

end

function Micro:ConstructionComplete()
	rotRadEye = math.rad(bodyRotation - 90.0)
	headPos = Vector.New(GetPlayerPosition())
	eyePos = Vector.Clone(headPos) 
	eyePos[1] = eyePos[1] + 18
	eyePos[2] = eyePos[2] + 3
	eyePos[1] = eyePos[1]  + (math.sin(rotRadEye) * 12.0)
	eyePos[2] = eyePos[2]  + (math.cos(rotRadEye) * 12.0)
	DrawTexture(microEye, eyePos[1], eyePos[2], -bodyRotation)	
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function Micro.PickupStart()
	OffsetPickupComponents(-5,2)
end


function Micro:OnInit(info)
	self.Base.OnInit(self, info)
	eyeGround = -1
	microGrind = -1
	--SetBirdOffset(9,2)
	SetDrawOffset(9,2)
	OverloadVehicleSounds()
	SetBirdEffects(false)
	microEye = LoadTexture("textures/Characters/Vehicles/Bird/Micro/microEye.xml", 11)
	microTail = LoadTexture("textures/Characters/Vehicles/Bird/Micro/microTail.xml", 10)
	microSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	Log("Init Particles!")
	microBubbles = CreateParticle("Micro_Bubbles")
	SetParticleEnabled(microBubbles, false)
	petBubbles = CreateParticle("Dog_Bubbles")
	SetParticleEnabled(petBubbles, false)
	fallingSoundPlaying = false
end

function Micro.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function Micro:Ready(skipPickupSeq)
	Log("Ready")
	PlayAnimation(microTail,"idle")
	VehicleUtils.PlaySong(self, "music", "ready")
	
	fallingSound = SFX.PlaySound("whale_flyLP",true)
	fallingSoundPlaying = true
end

function Micro.SetCurrentRotation(rotation)
	bodyRotation = rotation
end

function Micro:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	if(bubbleTimer > 0.0)then
		bubbleTimer = bubbleTimer - dt
	elseif(bubbleTimer < 0.0)then
		SetParticleEnabled(microBubbles, false)
		bubbleTimer = 0.0
	end
	if(petBubbleTimer > 0.0)then
		petBubbleTimer = petBubbleTimer - dt
	elseif(petBubbleTimer < 0.0)then
		SetParticleEnabled(petBubbles, false)
		petBubbleTimer = 0.0
	end

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end
end

function Micro:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	tailPos = Vector.Clone(headPos)
	eyePos = Vector.Clone(headPos) 
	sparksPos = Vector.Clone(headPos) 
	eyePos[1] = eyePos[1] + 18
	eyePos[2] = eyePos[2] + 3
	tailPos[1] = tailPos[1] + 17
	tailPos[2] = tailPos[2] + 6
	rotRad = math.rad(bodyRotation+90.0)
	rotRadEye = math.rad(bodyRotation - 90.0)
	eyePos[1] = eyePos[1]  + (math.sin(rotRadEye) * 12.0)
	eyePos[2] = eyePos[2]  + (math.cos(rotRadEye) * 12.0)
	DrawTexture(microEye, eyePos[1], eyePos[2], -bodyRotation)	
	tailPos[1] = tailPos[1] + math.sin(rotRad) * -42.0
	tailPos[2] = tailPos[2] + math.cos(rotRad) * -42.0
	
	DrawTexture(microTail, tailPos[1], tailPos[2], -bodyRotation)
	
	if(eyeGround == 1)then
		DrawTexture(microSparks, sparksPos[1], sparksPos[2] - 8)
	end
	worldPos = Vector.New(Level.GetOffset())
	
	bubbleParticlePos = headPos + Vector.New(-14.0, -5.0)
	
	finalBubbleParticlePos = bubbleParticlePos - worldPos
	SetParticlePosition(microBubbles, finalBubbleParticlePos[1], finalBubbleParticlePos[2])	
	
	if(IsDogActive() == true)then
		petPosition = Vector.New(GetDogPosition())
		petParticlePos = petPosition + Vector.New(-14.0, -5.0)
	
		finalpetParticlePos = petParticlePos - worldPos
		SetParticlePosition(petBubbles, finalpetParticlePos[1], finalpetParticlePos[2])	
	end

end

function Micro.HitRoof()
	Log("HitRoof")
end

function Micro.HitGround()
	PlayAnimation(microEye,"hitGround")
	PlayAnimation(microSparks,"landsparks")
	SFX.PlaySound("hover_land")
	eyeGround = 1
	if(playMicroGrind == -1)then
		microGrind = SFX.PlaySound("bird_slideLP",true)
		playMicroGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function Micro.CloseToCoins()
	PlayAnimation(microEye,"eat")
end

function Micro.FarFromCoins()
	PlayAnimation(microEye,"eatClose")
end

function Micro.TouchUp()

	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("whale_flyLP",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function Micro.TouchDown()
	Log("TouchDown")
end

function Micro.Jump()
	componentSound = math.random(3)
	Log("randomFlap = "..componentSound)
	bubbleTimer = 0.3
	SetParticleEnabled(microBubbles, true)
	if(eyeGround > 0)then
		PlayAnimation(microEye,"offGround")
		
		eyeGround = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("whale_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("whale_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("whale_vox_3")	
	end
	inputUp = false
	if(playMicroGrind == 1)then
		SFX.StopSound(microGrind or -1,0.5)
		playMicroGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
end

function Micro.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(microGrind or -1)
	playMicroGrind = -1
end

function Micro:OnDestroy()
	Log("OnDestroy")

	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function Micro.FlashToAnim_vehicleNoFlap()

end

function Micro.FlashToAnim_Flap()
	petBubbleTimer = 0.3
	SetParticleEnabled(petBubbles, true)
	
	dogFlap = math.random(3)
end

RegisterVehicle("Micro", "Bird", Micro);