Log("Magnet Suit Lua script started")

local MagnetSuit = {}
local headPos
local magnetTransition
local transitionNum = 0
--local switchParticle
local magnetBoots
local attractParticle
local landDust
local dustDraw = false
local roofLandParticle
local attractSound
local attractSoundPlaying = false

local lastAnimationFrame = -1

function MagnetSuit.GetTextureList()
	return "textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetTransition.tex|textures/Characters/RobotDog/Vehicles/MagnetSuit/magnetBoots.tex|textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetPositive.tex|textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetNegative.tex|textures/Characters/Vehicles/Hog/HoverHog/landDust.tex|textures/Characters/Vehicles/GravitySuit/MagnetSuit/smlmagnetPositive.tex|textures/Characters/Vehicles/GravitySuit/MagnetSuit/smlmagnetNegative.tex"
end

function MagnetSuit:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function MagnetSuit.ComponentComplete()

end

function MagnetSuit:ConstructionComplete()
	PlayAnimation(magnetBoots,"idle")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
	Log("Construction!")
end

function MagnetSuit.PickupStart()
	Log("Construction!")
end


function MagnetSuit:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	SetGravityEffectPaths("textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetNegative.xml","textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetPositive.xml","textures/Characters/Vehicles/GravitySuit/MagnetSuit/smlmagnetNegative.xml","textures/Characters/Vehicles/GravitySuit/MagnetSuit/smlmagnetPositive.xml")
	SetGravityEffectColours(0x80FFFFFF, 0xFFFFFFFF, 0x00FFFFFF, 0x80FFFFFF, 0xFFFFFFFF, 0x00FFFFFF)
	magnetTransition = LoadTexture("textures/Characters/Vehicles/GravitySuit/MagnetSuit/magnetTransition.xml", 9)
	magnetBoots = LoadTexture("textures/Characters/RobotDog/Vehicles/MagnetSuit/magnetBoots.xml", 15)
	landDust = LoadTexture("textures/Characters/Vehicles/Hog/HoverHog/landDust.xml", 10)
	attractParticle = CreateParticle("magnetSuit_Attract")
	SetParticleEnabled(attractParticle, false)
	roofLandParticle = CreateParticle("magnetSuit_Change")
	SetParticleEnabled(roofLandParticle, false)
	Log("Init Particles!")
	transitionNum = 0
	dustDraw = false
end

function MagnetSuit.PickupSequenceUpdate(dt)
end

function MagnetSuit:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
end

function MagnetSuit:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	anim, animationFrame = GetAnimationFrame(-1)
	if(anim == "drive_ceiling")then
		SFX.StopSound(attractSound or -1,0.05)
		attractSoundPlaying = false
		if(animationFrame == 5 and lastAnimationFrame ~= 5)then
			SFX.PlaySound("magnetron_step_left")
		elseif(animationFrame == 12 and lastAnimationFrame ~= 12)then
			SFX.PlaySound("magnetron_step_right")
		end
	end
	if(anim == "land_ceiling")then
		SFX.StopSound(attractSound or -1,0.05)
		attractSoundPlaying = false
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			PlayAnimation(landDust,"land")
			dustDraw = true
			SFX.PlaySound("magnetron_step_left")
			SetParticleEnabled(attractParticle, false)
			SetParticleEnabled(roofLandParticle, false)
		elseif(animationFrame == 2 and lastAnimationFrame ~= 2)then
			SetParticleEnabled(roofLandParticle, false)	
		elseif(animationFrame == 4 and lastAnimationFrame ~= 4)then
			SFX.PlaySound("magnetron_step_right")
		end
	end
	if(anim == "flip_up")then
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("magnetron_activate")
			--SetParticleEnabled(switchParticle, true)
			SetParticleEnabled(attractParticle, true)
		elseif(animationFrame == 3 and lastAnimationFrame ~= 3)then
			if(attractSoundPlaying == false)then
				attractSound = SFX.PlaySound("magnetron_flyLP",true)
				attractSoundPlaying = true
			end
			--SetParticleEnabled(switchParticle, false)
		end
	end
	if(anim == "flip_down")then
		SFX.StopSound(attractSound or -1,0.05)
		attractSoundPlaying = false
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("magnetron_deactivate")
			--SetParticleEnabled(switchParticle, true)
			SetParticleEnabled(attractParticle, false)
			SetParticleEnabled(roofLandParticle, false)
		elseif(animationFrame == 3 and lastAnimationFrame ~= 3)then
			--SetParticleEnabled(switchParticle, false)
		end
	end
	if(anim == "land")then
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("grav_land")
		end
	end
	if(anim == "drive")then
		if(animationFrame == 3 and lastAnimationFrame ~= 3)then
			rand = math.random(4)
			if(rand == 1)then
				SFX.PlaySound("grav_step_1")
			elseif(rand == 2)then
				SFX.PlaySound("grav_step_2")
			elseif(rand == 3)then
				SFX.PlaySound("grav_step_3")
			else
				SFX.PlaySound("grav_step_4")
			end
		elseif(animationFrame == 10 and lastAnimationFrame ~= 10)then
			rand = math.random(2)
			if(rand == 1)then
				SFX.PlaySound("grav_step_1")
			elseif(rand == 2)then
				SFX.PlaySound("grav_step_2")
			elseif(rand == 3)then
				SFX.PlaySound("grav_step_3")
			else
				SFX.PlaySound("grav_step_4")
			end
		end
	end
	
	lastAnim, lastAnimationFrame = GetAnimationFrame(-1)
	
	if(transitionNum > 0.0)then
		transitionNum = transitionNum - dt
	elseif(transitionNum < 0.0)then
		transitionNum = 0.0
	end
end

function RotateVector(vec, rot)
	x = math.cos(rot) * vec[1] - math.sin(rot) * vec[2];
	y = math.sin(rot) * vec[1] + math.cos(rot) * vec[2];
	retVec = Vector.New(x, y)
	return retVec;
end

function MagnetSuit:OnDraw()
	self.Base.OnDraw(self)
	
	worldPos = Vector.New(Level.GetOffset())
	headPos = Vector.New(GetPlayerPosition())
	
	if(transitionNum > 0.0)then
		DrawTexture(magnetTransition, headPos[1], headPos[2])
	end
	
	if(headPos[2] > 100)then
		SetParticleEnabled(attractParticle, false)
	end
	
	attractParticlePos = headPos + Vector.New(3.0, 25.0)
	SetParticlePosition(attractParticle, attractParticlePos[1], attractParticlePos[2])
	
	roofLandParticlePos = headPos + Vector.New(3.0, 25.0)
	SetParticlePosition(roofLandParticle, roofLandParticlePos[1], 145)
	
	if(dustDraw == true)then
		dustAnim, dustAnimationFrame = GetAnimationFrame(landDust)
		if(dustAnimationFrame == 3)then
			dustDraw = false
		end
	end
	
	if(IsDogActive() == true)then
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
		
		dogOffset = Vector.New(0.0,-8.0)
		dogOffset = RotateVector(dogOffset, math.rad(dogRotation))
		dogPosition = dogPosition + dogOffset
		DrawTexture(magnetBoots, dogPosition[1], dogPosition[2], dogRotation, dogScale[1], dogScale[2])
	end
end



function MagnetSuit.HitRoof()
	Log("HitRoof")
end

function MagnetSuit.LandCeiling()
	Log("HitRoof")
	SFX.PlaySound("magnetron_land")
	SetParticleEnabled(roofLandParticle, true)
end

function MagnetSuit.HitGround()
	Log("HitGround")
end

function MagnetSuit.TouchUp()
	inputUp = true
end

function MagnetSuit.TouchDown()
	transitionNum = 0.3
	PlayAnimation(magnetTransition,"transition")
end

function MagnetSuit.Explode()
	Log("Explode")
	if(attractSoundPlaying == true)then
		SFX.StopSound(attractSound or -1,0.2)
		attractSoundPlaying = false
	end
end

function MagnetSuit:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function MagnetSuit.FlashToAnim_jumpLaunch(startFrame)
	PlayAnimation(magnetBoots,"jumpLaunch",startFrame)
end

function MagnetSuit.FlashToAnim_land(startFrame)
	PlayAnimation(magnetBoots,"land",startFrame)
end

function MagnetSuit.FlashToAnim_run(startFrame)
	PlayAnimation(magnetBoots,"run",startFrame)
end

function MagnetSuit.FlashToAnim_tumbling(startFrame)
	PlayAnimation(magnetBoots,"tumbling",startFrame)
end

RegisterVehicle("MagnetSuit", "GravitySuit", MagnetSuit);