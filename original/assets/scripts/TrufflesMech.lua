Log("TrufflesMech Lua script started")

local TrufflesMech = {}
local headPos = 0
rocketTimer = 0.0
local running = false

local lastAnimationFrame = 0
local runDustLeft
local runDustRight
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
local boostSound = -1
local playBoost = -1

local deathParticles

local boostActive = false


function TrufflesMech.GetTextureList()
	return "textures/Characters/Vehicles/Components/Mech/TrufflesMech/ComponentTail.tex|textures/Characters/Vehicles/Components/Mech/TrufflesMech/ComponentBelt.tex|textures/Characters/Vehicles/Components/Mech/TrufflesMech/ComponentBody.tex|textures/Characters/Vehicles/Components/Mech/TrufflesMech/ComponentHead.tex|textures/Characters/Vehicles/Components/Mech/TrufflesMech/ComponentLeg.tex|textures/Characters/Vehicles/Components/Mech/TrufflesMech/ComponentLegFront.tex"
end
function TrufflesMech.ComponentComplete()

	componentSound = math.random(3)

	if(componentSound == 1)then
		SFX.PlaySound("truffles_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("truffles_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("truffles_form_3")
	end
	componentSound = 0
end

function TrufflesMech:ConstructionComplete()
	SFX.PlaySound("truffles_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function TrufflesMech:OnInit(info)
	self.Base.OnInit(self, info)
	OverloadVehicleSounds()
	OverloadPickupSounds()

	SetDrawBody(true)
	SetMechEffects(true)
	OverloadAllowHalo(true)

	runDustLeft = LoadTexture("textures/Effects/runDust.xml", 9)
	runDustRight = LoadTexture("textures/Effects/runDust.xml", 9)
	jumpDust = LoadTexture("textures/Effects/jumpDust.xml", 9)
	landDust = LoadTexture("textures/Effects/landDust.xml", 9)

	deathParticles = CreateParticle("Truffles_Smoke")	
	SetParticleEnabled(deathParticles, false)

	playBoost = -1
	--set a huge piece number so his body doesn't disappear
	SetConstructionBodyDisappearPieceNumber(99);
end

function TrufflesMech:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function TrufflesMech.PickupSequenceUpdate(dt)
end

function TrufflesMech:Ready(skipPickupSeq)
	Log("Ready")

	VehicleUtils.PlaySong(self, "music", "ready")
end

function TrufflesMech:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(running == true)then
		anim, animationFrame = GetAnimationFrame(-1)
		if(animationFrame == 7 and lastAnimationFrame ~= 7)then
			self.PlayStepSound()
			PlayAnimation(runDustLeft, "run")
			Level.ScreenShake(0.05,0.05)
			leftCounter = 0.5
			leftMove = 0.0
		elseif(animationFrame == 1 and lastAnimationFrame ~= 1)then
			self.PlayStepSound()
			Level.ScreenShake(0.05,0.05)
			PlayAnimation(runDustRight, "run")
			rightCounter = 0.5
			rightMove = 0.0
		end
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

function TrufflesMech:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	worldPos = Vector.New(Level.GetOffset())
	anim, runDustLeftFrame = GetAnimationFrame(runDustLeft)
	anim, runDustRightFrame = GetAnimationFrame(runDustRight)
	anim, jumpDustFrame = GetAnimationFrame(jumpDust)
	anim, landDustFrame = GetAnimationFrame(landDust)

	deathParticlesPos = headPos + Vector.New(15.0, 10.0)
	finalDeathParticlesPos = deathParticlesPos - worldPos

	if(runDustLeftFrame < 11)then
		DrawTexture(runDustLeft, (headPos[1] - leftMove), -110)
	end
	if(runDustRightFrame < 11)then
		DrawTexture(runDustRight, (headPos[1] - rightMove), -110)
	end
	if(jumpDustFrame < 5)then
		DrawTexture(jumpDust, (headPos[1] - moveJump), -70)
	end
	if(landDustFrame < 3)then
		DrawTexture(landDust, (headPos[1] - moveLand), -135)
	end

	pirateFeet = headPos + Vector.New(0.0, -12.0) - worldPos

	SetParticlePosition(deathParticles, finalDeathParticlesPos[1], finalDeathParticlesPos[2])

end

function TrufflesMech.HitGround()
	Log("HitGround")
	PlayAnimation(landDust, "land")
	SFX.PlaySound("truffles_land")
	Level.ScreenShake(0.2,5)
	landCounter = 0.4
	running = true

	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		playBoost = -1
	end

	boostActive = false
end


function TrufflesMech.OnJump()
	running = false
	PlayJumpSound()
	PlayAnimation(jumpDust, "jump")
	jumpCounter = 0.4
	Log("Jump!")
end

function TrufflesMech.TouchUp()
	inputUp = true
end

function TrufflesMech.TouchDown()
		inputUp = false
end

function TrufflesMech.PlayStepSound()
	stepSound = math.random(4)

	if(stepSound == 1)then
		Log("Playing step 1!")
		SFX.PlaySound("truffles_step_1")
	elseif(stepSound == 2)then
		Log("Playing step 2!")
		SFX.PlaySound("truffles_step_2")
	elseif(stepSound == 3)then
		Log("Playing step 3!")
		SFX.PlaySound("truffles_step_3")
	elseif(stepSound == 4)then
		Log("Playing step 4!")
		SFX.PlaySound("truffles_step_4")
	end
end

function TrufflesMech.StartBoost()
	Log("StartBoost")
	if(playBoost == -1)then
		boostSound = SFX.PlaySound("truffles_flutter_lp",true)
		playBoost = 1
	end

	boostActive = true
end

function TrufflesMech.StopBoost()
	Log("StopBoost")
		SFX.PlaySound("truffles_cooldown")
	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		playBoost = -1
	end

	boostActive = false
end

function TrufflesMech.FlameOn()
	Log("FlameOn")
end

function TrufflesMech.FlameOff()
	Log("FlameOff")
end

function TrufflesMech.Explode()
	Log("Explode")

	if(playBoost == 1)then
		Log("Stop Sound!!")
		SFX.StopSound(boostSound or -1,0.1)
		playBoost = -1
	end
	SetParticleEnabled(deathParticles, true)
	SFX.PlaySound("truffles_death")
end

function TrufflesMech:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function PlayJumpSound()
	jumpSound = math.random(3)

	if(jumpSound == 1)then
		Log("Playing jump 1!")
		SFX.PlaySound("truffles_jump_1")
	elseif(jumpSound == 2)then
		Log("Playing jump 2!")
		SFX.PlaySound("truffles_jump_2")
	elseif(jumpSound == 3)then
		Log("Playing jump 3!")
		SFX.PlaySound("truffles_jump_3")
	end
end

RegisterVehicle("TrufflesMech", "Mech", TrufflesMech);
