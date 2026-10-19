Log("Vampire Suit Lua script started")

local Vampire = {}
local headPos
local vampireTransition
local transitionNum = 0
--local switchParticle
local dogVampireEffect
local flyingSound
local flyingSoundPlaying = false

local lastAnimationFrame = -1

function Vampire.GetTextureList()
	return "textures/Characters/Vehicles/GravitySuit/Vampire/vampireSuitUpEffect.tex|textures/Characters/RobotDog/Vehicles/Vampire/dogVampireEffect.tex|textures/Characters/Vehicles/GravitySuit/Vampire/smlvampireSuitUpEffect.tex"
end

function Vampire:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Vampire.ComponentComplete()
end

function Vampire:ConstructionComplete()
	Log("Construction!")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function Vampire.PickupStart()
	Log("Construction!")
end


function Vampire:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	SetGravityEffectPaths("textures/Characters/Vehicles/GravitySuit/Vampire/vampireSuitDownEffect.xml","textures/Characters/Vehicles/GravitySuit/Vampire/vampireSuitUpEffect.xml","textures/Characters/Vehicles/GravitySuit/Vampire/smlvampireSuitDownEffect.xml","textures/Characters/Vehicles/GravitySuit/Vampire/smlvampireSuitUpEffect.xml")
	SetGravityEffectColours(0x80FFFFFF, 0xFFFFFFFF, 0x00FFFFFF, 0x80FFFFFF, 0xFFFFFFFF, 0x00FFFFFF)
	vampireTransition = LoadTexture("textures/Characters/Vehicles/GravitySuit/Vampire/vampireTransition.xml", 9)	
	dogVampireEffect = LoadTexture("textures/Characters/RobotDog/Vehicles/Vampire/dogVampireEffect.xml", 15)
	transitionNum = 0
end

function Vampire.PickupSequenceUpdate(dt)
end

function Vampire:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
end

function Vampire:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	anim, animationFrame = GetAnimationFrame(-1)

	if(anim == "flip_up")then
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("vampire_activate")
		elseif(animationFrame == 3 and lastAnimationFrame ~= 3)then
			if(flyingSoundPlaying == false)then
				flyingSound = SFX.PlaySound("vampire_flyLP",true)
				flyingSoundPlaying = true
			end
		end
	end

	if(anim == "flip_down")then
		SFX.StopSound(flyingSound or -1,0.05)
		flyingSoundPlaying = false

		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("vampire_deactivate")
		end
	end

	if(anim == "land")then
		if(animationFrame == 1 and lastAnimationFrame ~= 1)then
			SFX.PlaySound("vampire_land")
		end
	end

	if(anim == "drive")then
		if(animationFrame == 3 and lastAnimationFrame ~= 3)then
			rand = math.random(4)
			if(rand == 1)then
				SFX.PlaySound("vampire_step_1")
			elseif(rand == 2)then
				SFX.PlaySound("vampire_step_2")
			elseif(rand == 3)then
				SFX.PlaySound("vampire_step_3")
			else
				SFX.PlaySound("vampire_step_4")
			end

		elseif(animationFrame == 10 and lastAnimationFrame ~= 10)then
			rand = math.random(2)
			if(rand == 1)then
				SFX.PlaySound("vampire_step_1")
			elseif(rand == 2)then
				SFX.PlaySound("vampire_step_2")
			elseif(rand == 3)then
				SFX.PlaySound("vampire_step_3")
			else
				SFX.PlaySound("vampire_step_4")
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

function Vampire:OnDraw()
	self.Base.OnDraw(self)
	
	worldPos = Vector.New(Level.GetOffset())
	headPos = Vector.New(GetPlayerPosition())
	
	if(transitionNum > 0.0)then
		DrawTexture(vampireTransition, headPos[1], headPos[2])
	end
			
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
		DrawTexture(dogVampireEffect, dogPosition[1], dogPosition[2], dogRotation, dogScale[1], dogScale[2])
	end
end



function Vampire.HitRoof()
	Log("HitRoof")
end

function Vampire.LandCeiling()
	Log("HitRoof")
	SFX.PlaySound("vampire_land")
end

function Vampire.HitGround()
	Log("HitGround")
end

function Vampire.TouchUp()
	inputUp = true
end

function Vampire.TouchDown()
	transitionNum = 0.3
	PlayAnimation(vampireTransition,"transition")
end

function Vampire.Explode()
	Log("Explode")
	SFX.PlaySound("vampire_death")
	if(flyingSoundPlaying == true)then
		SFX.StopSound(flyingSound or -1,0.2)
		flyingSoundPlaying = false
	end
end

function Vampire:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function Vampire.FlashToAnim_run(startFrame)
	PlayAnimation(dogVampireEffect,"run",startFrame)
end

function Vampire.FlashToAnim_tumbling(startFrame)
	PlayAnimation(dogVampireEffect,"tumbling",startFrame)
end

RegisterVehicle("Vampire", "GravitySuit", Vampire); 