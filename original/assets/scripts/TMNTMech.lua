Log("TMNTMech Lua script started")

local TMNTMech = {}
local rocketFlame
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

function TMNTMech.GetTextureList()
	return "textures/Characters/Vehicles/Mech/TMNTMech/vehicleMechFlame.tex"
end
function TMNTMech.ComponentComplete()

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

function TMNTMech.ConstructionComplete()
	SFX.PlaySound("tmnt_mouser_form_complete")
end

function TMNTMech:OnInit(info)
	self.Base.OnInit(self, info)
	OverloadVehicleSounds()
	OverloadPickupSounds()

	SetDrawBody(true)
	SetMechEffects(true)
	SetMechFlameOffset(0, -7)
	OverloadAllowHalo(true)

	runDustLeft = LoadTexture("textures/Effects/runDust.xml", 9)
	runDustRight = LoadTexture("textures/Effects/runDust.xml", 9)
	jumpDust = LoadTexture("textures/Effects/jumpDust.xml", 9)
	landDust = LoadTexture("textures/Effects/landDust.xml", 9)

	playBoost = -1
	--set a huge piece number so his body doesn't disappear
	SetConstructionBodyDisappearPieceNumber(99);
end

function TMNTMech.PickupSequenceUpdate(dt)
end

function TMNTMech:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(running == true)then
		anim, animationFrame = GetAnimationFrame(-1)
		if(animationFrame == 8 and lastAnimationFrame ~= 8)then
			self.PlayStepSound()
			PlayAnimation(runDustLeft, "run")
			Level.ScreenShake(0.2,0.2)
			leftCounter = 0.4
			leftMove = 0.0
		elseif(animationFrame == 1 and lastAnimationFrame ~= 1)then
			self.PlayStepSound()
			Level.ScreenShake(0.2,0.2)
			PlayAnimation(runDustRight, "run")
			rightCounter = 0.4
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

function TMNTMech:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	worldPos = Vector.New(Level.GetOffset())
	anim, runDustLeftFrame = GetAnimationFrame(runDustLeft)
	anim, runDustRightFrame = GetAnimationFrame(runDustRight)
	anim, jumpDustFrame = GetAnimationFrame(jumpDust)
	anim, landDustFrame = GetAnimationFrame(landDust)

	if(runDustLeftFrame < 11)then
		DrawTexture(runDustLeft, (headPos[1] + 10 - leftMove), -110)
	end
	if(runDustRightFrame < 11)then
		DrawTexture(runDustRight, (headPos[1] - rightMove), -115)
	end
	if(jumpDustFrame < 5)then
		DrawTexture(jumpDust, (headPos[1] - moveJump), -70)
	end
	if(landDustFrame < 3)then
		DrawTexture(landDust, (headPos[1] - moveLand), -135)
	end
end

function TMNTMech.HitGround()
	Log("HitGround")
	PlayAnimation(landDust, "land")
	SFX.PlaySound("tmnt_mouser_land")
	Level.ScreenShake(0.2,5)
	landCounter = 0.4
	running = true

	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		playBoost = -1
	end
end


function TMNTMech.OnJump()
	running = false
	SFX.PlaySound("tmnt_mouser_jump")
	PlayAnimation(jumpDust, "jump")
	jumpCounter = 0.4
	Log("Jump!")
end

function TMNTMech.TouchUp()
	inputUp = true
end

function TMNTMech.TouchDown()
		inputUp = false
end

function TMNTMech.PlayStepSound()
	stepSound = math.random(4)

	if(stepSound == 1)then
		Log("Playing step 1!")
		SFX.PlaySound("tmnt_mouser_step_01")
	elseif(stepSound == 2)then
		Log("Playing step 2!")
		SFX.PlaySound("tmnt_mouser_step_02")
	elseif(stepSound == 3)then
		Log("Playing step 3!")
		SFX.PlaySound("tmnt_mouser_step_03")
	elseif(stepSound == 4)then
		Log("Playing step 4!")
		SFX.PlaySound("tmnt_mouser_step_04")
	end
end

function TMNTMech.StartBoost()
	Log("StartBoost")
	if(playBoost == -1)then
		boostSound = SFX.PlaySound("tmnt_mouser_boost_lp",true)
		playBoost = 1
	end
end

function TMNTMech.StopBoost()
	Log("StopBoost")
	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		SFX.PlaySound("tmnt_mouser_cooldown")
		playBoost = -1
	end


end

function TMNTMech.FlameOn()
	Log("FlameOn")
end

function TMNTMech.FlameOff()
	Log("FlameOff")
end

function TMNTMech.Explode()
	Log("Explode")

	if(playBoost == 1)then
		Log("Stop Sound!!")
		SFX.StopSound(boostSound or -1,0.1)
		playBoost = -1
	end

	SFX.PlaySound("tmnt_mouser_explode")
end

function TMNTMech:OnDestroy()
	self.Base.OnDestroy(self)
end

RegisterVehicle("TMNTMech", "Mech", TMNTMech);
