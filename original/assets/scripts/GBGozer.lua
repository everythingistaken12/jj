Log("Gozer Lua script started")

local GBGozer = {}
local headPos
local transitionNum = 0
local dogGozerEffect
local attractSound
local attractSoundPlaying = false

local lastAnimationFrame = -1

local lightningActive = false
local lightning = {}
local lightningRanges = {}
local currentLightning = 0
local nextLightningDelay = 0

-- constants
local maxLightnings = 50
local LightningTexture = "particles/gozerLightning.tex"
local LightningDelay = 0.066
local offsets = { 0.0, 15.0 }

function GetCurrentRange()
	local y = Vector.New(GetPlayerPosition())[2] + 120;
	local range = 0.5773 * y
	return range
end

function GBGozer.GetTextureList()
	return "textures/Characters/RobotDog/Vehicles/GBGozer/dogGBGozerEffect.tex|textures/Characters/Vehicles/Hog/HoverHog/landDust.tex|"..LightningTexture
end

function GBGozer:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function GBGozer.ComponentComplete()
end

function GBGozer:ConstructionComplete()
	Log("Construction!")
	PlayAnimation(dogGozerEffect,"idle")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function GBGozer.PickupStart()
	Log("Construction!")
end

function GBGozer:OnInit(info)
	self.Base.OnInit(self, info)

	for i = 1, maxLightnings do
		lightning[i] = -1
		lightningRanges[i] = -1
	end
	
	SetGravityEffectPaths("textures/Characters/Vehicles/GravitySuit/GBGozer/magnetNegative.xml","textures/Characters/Vehicles/GravitySuit/GBGozer/magnetPositive.xml","textures/Characters/Vehicles/GravitySuit/GBGozer/smlmagnetNegative.xml","textures/Characters/Vehicles/GravitySuit/GBGozer/smlmagnetPositive.xml")

	OverloadVehicleSounds()
	dogGozerEffect = LoadTexture("textures/Characters/RobotDog/Vehicles/GBGozer/dogGBGozerEffect.xml", 15)

	transitionNum = 0
end

function GBGozer.PickupSequenceUpdate(dt)
end

function GBGozer:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
end

function GBGozer:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if (nextLightningDelay > 0) then
		nextLightningDelay = nextLightningDelay - dt
	end

	anim, animationFrame = GetAnimationFrame(-1)

	if(anim == "flip_up")then
		lightningActive = true
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("gb_gozer_activate")
		elseif(animationFrame == 3 and lastAnimationFrame ~= 3)then
			if(attractSoundPlaying == false)then
				attractSound = SFX.PlaySound("gb_gozer_fly_lp",true)
				attractSoundPlaying = true
			end
		end
	end

	if(anim == "flip_down")then
		lightningActive = false
		SFX.StopSound(attractSound or -1,0.05)
		attractSoundPlaying = false

		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("gb_gozer_deactivate")
		end
	end

	if(anim == "land")then
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("land_metal")
		end
	end

	if(anim == "drive")then
		if(animationFrame == 3 and lastAnimationFrame ~= 3)then
			rand = math.random(4)
			if(rand == 1)then
				SFX.PlaySound("run_metal_left_1")
			elseif(rand == 2)then
				SFX.PlaySound("run_metal_left_2")
			elseif (rand == 3) then
				SFX.PlaySound("run_metal_left_3")
			else
				SFX.PlaySound("run_metal_left_4")
			end

		elseif(animationFrame == 10 and lastAnimationFrame ~= 10)then
			rand = math.random(2)
			if(rand == 1)then
				SFX.PlaySound("run_metal_right_1")
			elseif (rand == 2) then
				SFX.PlaySound("run_metal_right_2")
			elseif (rand == 3) then
				SFX.PlaySound("run_metal_right_3")
			else
				SFX.PlaySound("run_metal_right_4")
			end
		end
	end
	
	lastAnim, lastAnimationFrame = GetAnimationFrame(-1)
	
	if(transitionNum > 0.0)then
		transitionNum = transitionNum - dt
	elseif(transitionNum < 0.0)then
		transitionNum = 0.0
	end

	for i = 1, maxLightnings do
		if (lightning[i] ~= -1 and UpdateLightning(lightning[i], false)) then
			DestroyLightning(lightning[i])
			lightning[i] = -1
			currentLightning = currentLightning - 1
		end
	end

	local range = GetCurrentRange()

	if (currentLightning < maxLightnings and lightningActive and nextLightningDelay <= 0) then
		for i = 1, maxLightnings  do
			if (lightning[i] == -1) then
				local ran = math.random(1, 2)
				local offsetx = offsets[ran]
				lightning[i] = CreateLightning(LightningTexture, "", offsetx, 0.0)
				SetLightningRange(lightning[i], -range, range)
				lightningRanges[i] = range
				currentLightning = currentLightning + 1
				nextLightningDelay = LightningDelay
				break
			end
		end
	end

	for i = 1, maxLightnings  do
		if (lightning[i] ~= -1) then
			if (math.abs(lightningRanges[i] - range) > 15.0) then
				SetLightningRange(lightning[i], -range, range)
				lightningRanges[i] = range
			end
		end
	end

end

function RotateVector(vec, rot)
	x = math.cos(rot) * vec[1] - math.sin(rot) * vec[2];
	y = math.sin(rot) * vec[1] + math.cos(rot) * vec[2];
	retVec = Vector.New(x, y)
	return retVec;
end

function GBGozer:OnDraw()
	self.Base.OnDraw(self)
	
	worldPos = Vector.New(Level.GetOffset())
	headPos = Vector.New(GetPlayerPosition())
			
	roofLandParticlePos = headPos + Vector.New(3.0, 25.0)
		
	if(IsDogActive() and anim ~= "drive")then
		dogPosition = Vector.New(GetDogPosition())
		dogRotation = GetDogRotation()
		dogScale = Vector.New(GetDogScale())
		
		if(dogScale[1] < 0)then
			dogScale[1] = -dogScale[1]
		end
		
		if(dogScale[2] < 0)then
			dogRotation = dogRotation + 180
			dogScale[1] = -dogScale[1]
			dogScale[2] = -dogScale[2]
		end
		
		dogOffset = Vector.New(0.0,0.0)
		dogOffset = RotateVector(dogOffset, math.rad(dogRotation))
		dogPosition = dogPosition + dogOffset
		DrawTexture(dogGozerEffect, dogPosition[1], dogPosition[2], dogRotation, dogScale[1], dogScale[2])
	end

	for i = 1, maxLightnings do
		if (lightning[i] ~= -1) then
			DrawLightning(lightning[i])
		end
	end
end

function GBGozer.HitRoof()
	Log("HitRoof")
end

function GBGozer.LandCeiling()
	Log("HitRoof")
	SFX.PlaySound("vampire_land")
end

function GBGozer.HitGround()
	Log("HitGround")
end

function GBGozer.TouchUp()
	inputUp = true
end

function GBGozer.TouchDown()
	transitionNum = 0.3
end

function GBGozer.Explode()
	Log("Explode")
	SFX.PlaySound("gb_gozer_destroy")
	if(attractSoundPlaying == true)then
		SFX.StopSound(attractSound or -1,0.2)
		attractSoundPlaying = false
	end
end

function GBGozer:OnDestroy()
	for i = 1, maxLightnings do
		if (lightning[i] ~= -1) then
			DestroyLightning(lightning[i])
			lightning[i] = -1
		end
	end
	currentLightning = 0
	lightningActive = false

	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function GBGozer.FlashToAnim_run(startFrame)
	PlayAnimation(dogGozerEffect,"run",startFrame)
end

function GBGozer.FlashToAnim_tumbling(startFrame)
	PlayAnimation(dogGozerEffect,"tumbling",startFrame)
end

RegisterVehicle("GBGozer", "GravitySuit", GBGozer);