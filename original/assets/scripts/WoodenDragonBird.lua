Log("WoodenDragonBird Lua script started")

local WoodenDragonBird = {}
local birdSparks
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1
local fireBurpParticles
local fireBurpTimer = 0.0
local fireBurpFinished = 0.0
local dragonTassel
local bodyRotation = 0.0

local fallingSound
local fallingSoundPlaying = false

function WoodenDragonBird.GetTextureList()
	return "textures/Characters/Vehicles/Bird/WoodenDragonBird/woodenDragonTassel.tex"
end

function WoodenDragonBird:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function WoodenDragonBird.ComponentComplete()

end

function WoodenDragonBird:ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("wood_dragon_formation_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function WoodenDragonBird.PickupStart()
	OffsetPickupComponents(-5,2)

    constructionSound = math.random(3)
end

function WoodenDragonBird.ComponentComplete()
    if(constructionSound == 1)then
        SFX.PlaySound("wood_dragon_formation_1")
        constructionSound = math.random(3)
    elseif(constructionSound == 2)then
        SFX.PlaySound("wood_dragon_formation_2")
        constructionSound = math.random(3)
    elseif(constructionSound == 3)then
        SFX.PlaySound("wood_dragon_formation_3")
        constructionSound = math.random(3)
    end
end


function WoodenDragonBird:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	OverloadPickupSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	dragonTassel = LoadTexture("textures/Characters/Vehicles/Bird/WoodenDragonBird/woodenDragonTassel.xml", 11)
	fallingSoundPlaying = false	

	fireBurpParticles = CreateParticle("Lantern_Explosion")
	SetParticleEnabled(fireBurpParticles, false)
end

function WoodenDragonBird.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function WoodenDragonBird:Ready(skipPickupSeq)
	Log("Ready")
	
	VehicleUtils.PlaySong(self, "music", "ready")

	fallingSound = SFX.PlaySound("bird_flyLP",true)
	fallingSoundPlaying = true

	PlayAnimation(dragonTassel,"idle")
end

function WoodenDragonBird.SetCurrentRotation(rotation)
	bodyRotation = rotation
end

function WoodenDragonBird:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(fallingSoundPlaying == true)then
		local volume = VehicleUtils.GetFallingSoundVolume(6)
		SFX.SetSoundVolume(fallingSound, volume)
	end

	if(fireBurpTimer > 0.0)then
		fireBurpTimer = fireBurpTimer - dt
	elseif(fireBurpTimer < 0.0)then
		self.Burp()
		fireBurpTimer = 0.0
		fireBurpFinished = 0.3
	end	

	if(fireBurpFinished > 0.0)then
		fireBurpFinished = fireBurpFinished - dt
	elseif(fireBurpFinished < 0.0)then
		fireBurpFinished = 0.0
		SetParticleEnabled(fireBurpParticles, false)
		Log("Burp Finished")
	end	
end

function WoodenDragonBird:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	sparksPos = Vector.Clone(headPos)
	tasselPos = Vector.Clone(headPos)

	rotRad = math.rad(bodyRotation+90.0)

	tasselPos[1] = tasselPos[1] + math.sin(rotRad) * -42.0
	tasselPos[2] = tasselPos[2] + 15 + math.cos(rotRad) * -42.0
	
	if(ground == 1)then
		DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end

	worldPos = Vector.New(Level.GetOffset())

	fireBurpParticlePos = headPos + Vector.New(30.0, -5.0)
	finalFireBurpParticlePos = fireBurpParticlePos - worldPos	
	SetParticlePosition(fireBurpParticles, finalFireBurpParticlePos[1], finalFireBurpParticlePos[2])

	DrawTexture(dragonTassel, tasselPos[1], tasselPos[2], -bodyRotation)
end

function WoodenDragonBird.HitRoof()
	Log("HitRoof")
end

function WoodenDragonBird.HitGround()
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("wood_dragon_land")
	ground = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("wood_dragon_slide_lp",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function WoodenDragonBird.CloseToCoins()
	fireBurpTimer = 2.0
	SFX.PlaySound("wood_dragon_mouth_open")
end

function WoodenDragonBird.FarFromCoins()
	fireBurpTimer = 1.0
	SFX.PlaySound("wood_dragon_mouth_close")
end

function WoodenDragonBird.Burp()
	if(componentSound == 1)then
		SFX.PlaySound("wood_dragon_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("wood_dragon_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("wood_dragon_vox_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("wood_dragon_vox_4")
	end

	SetParticleEnabled(fireBurpParticles, true)

	fireBurpFinished = 0.0

	Log("Burp")
end


function WoodenDragonBird.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("bird_flyLP",true)
		fallingSoundPlaying = true
	end
	inputUp = true
end

function WoodenDragonBird.TouchDown()
	Log("TOUCH")
end

function WoodenDragonBird.Jump()
	componentSound = math.random(3)

	if(ground > 0)then		
		ground = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("wood_dragon_flap_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("wood_dragon_flap_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("wood_dragon_flap_3")
	elseif(componentSound == 4)then		
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
end

function WoodenDragonBird.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("wood_dragon_explode")
	playBirdGrind = -1
end

function WoodenDragonBird:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function WoodenDragonBird.FlashToAnim_vehicleNoFlap()

end

function WoodenDragonBird.FlashToAnim_Flap()
	dogFlap = math.random(3)
end

RegisterVehicle("WoodenDragonBird", "Bird", WoodenDragonBird);
