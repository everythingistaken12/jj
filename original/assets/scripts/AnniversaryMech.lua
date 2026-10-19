Log("AnniversaryMech Lua script started")

local AnniversaryMech = {}
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

function AnniversaryMech.GetTextureList()
	return "textures/Characters/Vehicles/Components/Mech/AnniversaryMech/ComponentTail.tex" ..
	"|textures/Characters/Vehicles/Components/Mech/AnniversaryMech/ComponentBelt.tex" ..
	"|textures/Characters/Vehicles/Components/Mech/AnniversaryMech/ComponentBody.tex" ..
	"|textures/Characters/Vehicles/Components/Mech/AnniversaryMech/ComponentHead.tex" ..
	"|textures/Characters/Vehicles/Components/Mech/AnniversaryMech/ComponentLeg.tex" ..
	"|textures/Characters/Vehicles/Components/Mech/AnniversaryMech/ComponentLegFront.tex" ..
	"|textures/Characters/Vehicles/Mech/AnniversaryMech/vehicleMechFlame.tga"
end
function AnniversaryMech.ComponentComplete()

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

function AnniversaryMech.ConstructionComplete()
	SFX.PlaySound("vehicle_form_complete")
end

function AnniversaryMech:OnInit(info)
	self.Base.OnInit(self, info)
	OverloadVehicleSounds()
	OverloadPickupSounds()

	SetDrawBody(true)
	SetMechEffects(true)
	OverloadAllowHalo(true)

    SetMechFlameOffset(2,-16)


	runDustLeft = LoadTexture("textures/Effects/runDust.xml", 9)
	runDustRight = LoadTexture("textures/Effects/runDust.xml", 9)
	jumpDust = LoadTexture("textures/Effects/jumpDust.xml", 9)
	landDust = LoadTexture("textures/Effects/landDust.xml", 9)

	playBoost = -1
	--set a huge piece number so his body doesn't disappear
	SetConstructionBodyDisappearPieceNumber(99);
end

function AnniversaryMech.PickupSequenceUpdate(dt)
end

function AnniversaryMech:OnUpdate(dt)
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

function AnniversaryMech:OnDraw()
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

function AnniversaryMech.HitGround()
	Log("HitGround")
	PlayAnimation(landDust, "land")
	SFX.PlaySound("mech_land")
	Level.ScreenShake(0.2,5)
	landCounter = 0.4
	running = true

	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		playBoost = -1
	end
end


function AnniversaryMech.OnJump()
	running = false
	SFX.PlaySound("mech_jump")
	PlayAnimation(jumpDust, "jump")
	jumpCounter = 0.4
	Log("Jump!")
end

function AnniversaryMech.TouchUp()
	inputUp = true
end

function AnniversaryMech.TouchDown()
		inputUp = false
end

function AnniversaryMech.PlayStepSound()
	stepSound = math.random(4)

	if(stepSound == 1)then
		Log("Playing step 1!")
		SFX.PlaySound("mech_step_1")
	elseif(stepSound == 2)then
		Log("Playing step 2!")
		SFX.PlaySound("mech_step_2")
	elseif(stepSound == 3)then
		Log("Playing step 3!")
		SFX.PlaySound("mech_step_3")
	elseif(stepSound == 4)then
		Log("Playing step 4!")
		SFX.PlaySound("mech_step_4")
	end
end

function AnniversaryMech.StartBoost()
	Log("StartBoost")
	if(playBoost == -1)then
		boostSound = SFX.PlaySound("mech_boost_lp",true)
		playBoost = 1
	end
end

function AnniversaryMech.StopBoost()
	Log("StopBoost")
	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		SFX.PlaySound("mech_cooldown")
		playBoost = -1
	end


end

function AnniversaryMech.FlameOn()
	Log("FlameOn")
end

function AnniversaryMech.FlameOff()
	Log("FlameOff")
end

function AnniversaryMech.Explode()
	Log("Explode")

	if(playBoost == 1)then
		Log("Stop Sound!!")
		SFX.StopSound(boostSound or -1,0.1)
		playBoost = -1
	end

	SFX.PlaySound("mech_explode")
end

function AnniversaryMech:OnDestroy()
	self.Base.OnDestroy(self)
end

RegisterVehicle("AnniversaryMech", "Mech", AnniversaryMech);
