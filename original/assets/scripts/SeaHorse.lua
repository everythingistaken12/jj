Log("SeaHorse Lua script started")

local SeaHorse = {}
local rocketFlame
local headPos = 0
rocketTimer = 0.0
local running = false
local lastAnimationFrame = 0
local seaHorseSparks
local jumpDust
local landDust
local leftCounter = 0.0
local leftMove = 0.0
local rightMove = 0.0
local rightCounter = 0.0
local moveJump = 0.0
local moveLand = 0.0
local jumpCounter = 0.0
local landCounter = 0.0
local flutterSound = -1
local playFlutter = -1
local bodyGround = -1
local playSeahorseGrind = -1
local seaHorseGrind
local seaHorseBody

function SeaHorse.GetTextureList()
	return "textures/Characters/Vehicles/Components/Mech/SeaHorse/ComponentTail.tex|textures/Characters/Vehicles/Components/Mech/SeaHorse/ComponentBelt.tex|textures/Characters/Vehicles/Components/Mech/SeaHorse/ComponentBody.tex|textures/Characters/Vehicles/Components/Mech/SeaHorse/ComponentHead.tex|textures/Characters/Vehicles/Components/Mech/SeaHorse/ComponentLeg.tex|textures/Characters/Vehicles/Components/Mech/SeaHorse/ComponentLegFront.tex|textures/Characters/Vehicles/Mech/SeaHorse/vehicleMechFlame.tga"
end

function SeaHorse:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function SeaHorse.ComponentComplete()

	componentSound = math.random(3)

	if(componentSound == 1)then
		SFX.PlaySound("vehicle_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("vehicle_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("vehicle_form_3")
	end
	componentSound = 0
end

function SeaHorse:ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("seahorse_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function SeaHorse:OnInit(info)
	Log("Zombie init!")
	seaHorseGrind = -1	
	self.Base.OnInit(self, info)
	playFlutter = -1
	OverloadVehicleSounds()
	OverloadPickupSounds()
	SetDrawBody(true)
	SetMechEffects(false)
	OverloadAllowHalo(true)
	seaHorseSparks = LoadTexture("textures/Effects/seaHorseSparks.xml", 11)
	jumpDust = LoadTexture("textures/Effects/jumpDust.xml", 9)
	landDust = LoadTexture("textures/Effects/landDust.xml", 9)

	--set a huge piece number so his body doesn't disappear
	SetConstructionBodyDisappearPieceNumber(99);
end

function SeaHorse.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function SeaHorse:Ready(skipPickupSeq)
	Log("Ready")

	VehicleUtils.PlaySong(self, "music", "ready")
end

function SeaHorse:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	if(running == true)then
		anim, animationFrame = GetAnimationFrame(-1)
		randomHorse = math.random(2)
		if(animationFrame == 2 and lastAnimationFrame ~= 2)then
			SFX.PlaySound("seahorse_step_0"..randomHorse)

			Level.ScreenShake(0.05,0.05)
			leftCounter = 0.4
			leftMove = 0.0
		elseif(animationFrame == 6 and lastAnimationFrame ~= 6)then
			SFX.PlaySound("seahorse_step_0"..(2 + randomHorse))
			Level.ScreenShake(0.05,0.05)
			HorseVoice()

			rightCounter = 0.4
			rightMove = 0.0
		end
		randomHorse = 0
	end
	anim, lastAnimationFrame = GetAnimationFrame(-1)

	if(leftCounter > 0.0)then
		leftCounter = leftCounter - dt
		leftMove = leftMove + 2
		--Log("LeftMove "..leftMove)
	end
	if(leftCounter < 0.0)then
		leftCounter = 0.0
	end
	if(rightCounter > 0.0)then
		rightCounter = rightCounter - dt
		rightMove = rightMove + 2
		--Log("RightMove "..rightMove)
	end
	if(rightCounter < 0.0)then
		rightCounter = 0.0
	end

	if(jumpCounter > 0.0)then
		jumpCounter = jumpCounter - dt
		moveJump = moveJump + 2
	end
	if(jumpCounter < 0.0)then
		jumpCounter = 0.0
		moveJump = 0.0
	end

	if(landCounter > 0.0)then
		landCounter = landCounter - dt
		moveLand = moveLand + 2
	end
	if(landCounter < 0.0)then
		landCounter = 0.0
		moveLand = 0.0
	end

end

function SeaHorse:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	anim, jumpDustFrame = GetAnimationFrame(jumpDust)
	anim, landDustFrame = GetAnimationFrame(landDust)

	if(bodyGround == 1)then
		DrawTexture(seaHorseSparks, headPos[1], headPos[2] - 8)
	end	

	if(jumpDustFrame < 5)then
		DrawTexture(jumpDust, (headPos[1] - moveJump), -70)
	end
	if(landDustFrame < 3)then
		DrawTexture(landDust, (headPos[1] - moveLand), -135)
	end
end

function SeaHorse.HitGround()
	Log("HitGround")
	SFX.PlaySound("seahorse_land")
	PlayAnimation(landDust, "land")
	Level.ScreenShake(0.2,2)
	landCounter = 0.4
	bodyGround = 1	

	if(playFlutter == 1)then
		SFX.StopSound(flutterSound or -1)
		playFlutter = -1
	end
	
	if(playSeahorseGrind == -1)then
		seaHorseGrind = SFX.PlaySound("bird_slideLP",true)
		playSeahorseGrind = 1
	end	
	running = true
end

function SeaHorse.OnJump()
	running = false
	SFX.PlaySound("seahorse_jump")
	PlayAnimation(jumpDust, "jump")
	jumpCounter = 0.4
	Log("Jump!")
end

function SeaHorse.TouchUp()
	inputUp = true
end

function SeaHorse.TouchDown()

		inputUp = false
		if(bodyGround > 0)then
			bodyGround = -1
		end
	if(playSeahorseGrind == 1)then
		SFX.StopSound(seaHorseGrind or -1,0.5)
		playSeahorseGrind = -1
	end			
end

function SeaHorse.StartBoost()
	HorseVoice()
	if(playFlutter == -1)then
		Log("Play Sound!!")
		flutterSound = SFX.PlaySound("seahorse_flutter_lp",true)
		playFlutter = 1
	end
	Log("StartBoost")
	Log("StartBoost playFlutter= "..playFlutter)
end

function SeaHorse.StopBoost()
	Log("StopBoostPre playFlutter= "..playFlutter)
	if(playFlutter == 1)then
		SFX.StopSound(flutterSound or -1)
		Log("Stop Sound!!")
		playFlutter = -1
	end
	Log("StopBoostPost playFlutter= "..playFlutter)
	Log("StopBoost")
end

function SeaHorse.FlameOn()
	Log("FlameOn")
end

function SeaHorse.FlameOff()
	Log("FlameOff")
end

function SeaHorse.Explode()
	Log("Explode")
	if(playFlutter == 1)then
		Log("Stop Sound!!")
		SFX.StopSound(flutterSound or -1,0.1)
		playFlutter = -1
	end
	
	SFX.StopSound(seaHorseGrind or -1)
	seaHorseGrind = -1			

	SFX.PlaySound("seahorse_death")
end

function SeaHorse:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function HorseVoice()
	randomHorse = math.random(8)

	if(randomHorse >= 1 and randomHorse <= 4)then
		SFX.PlaySound("seahorse_vox_0"..randomHorse)
	end

	randomHorse = 0
end

function SeaHorse.FlashToAnim_land()

end

function SeaHorse.FlashToAnim_run()

end

function SeaHorse.FlashToAnim_jumpLaunch()

end

RegisterVehicle("SeaHorse", "Mech", SeaHorse);
