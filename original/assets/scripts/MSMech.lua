Log("MS Mech Lua script started")

local MSMech = {}
local rocketFlame
local headPos = 0
rocketTimer = 0.0
local running = false

local lastAnimationFrame = 0
local runDustLeft
local runDustRight
local jumpDust
local landDust
local moveJump = 0.0
local moveLand = 0.0
local jumpCounter = 0.0
local landCounter = 0.0
local boostSound = -1
local playBoost = -1
local moveSound = -1
local playMove = -1


function MSMech.GetTextureList()
	return "textures/Characters/Vehicles/Components/Mech/MSMech/ComponentTail.tex|textures/Characters/Vehicles/Components/Mech/MSMech/ComponentBelt.tex|textures/Characters/Vehicles/Components/Mech/MSMech/ComponentBody.tex|textures/Characters/Vehicles/Components/Mech/MSMech/ComponentHead.tex|textures/Characters/Vehicles/Components/Mech/MSMech/ComponentLeg.tex|textures/Characters/Vehicles/Components/Mech/MSMech/ComponentLegFront.tex|textures/Characters/Vehicles/Mech/MSMech/vehicleMechFlame.tga"
end
function MSMech.ComponentComplete()

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

function MSMech.ConstructionComplete()
	SFX.PlaySound("ms_vehicle_form_complete")
end

function MSMech:OnInit(info)
	self.Base.OnInit(self, info)
	OverloadVehicleSounds()
	OverloadPickupSounds()

	SetDrawBody(true)
	local drawEffectsAboveSprite = true -- optional
	SetMechEffects(true, drawEffectsAboveSprite)
	SetMechFlameOffset(9, 5)

	jumpDust = LoadTexture("textures/Effects/jumpDust.xml", 9)
	landDust = LoadTexture("textures/Effects/landDust.xml", 9)

	playBoost = -1
	playMove = -1

	SetConstructionBodyDisappearPieceNumber(99);
end

function MSMech.PickupSequenceUpdate(dt)
end

function MSMech:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	anim, lastAnimationFrame = GetAnimationFrame(-1)

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

function MSMech:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
end

function MSMech.HitGround()
	Log("HitGround")
	PlayAnimation(landDust, "land")
	SFX.PlaySound("ms_mech_land")
	Level.ScreenShake(0.2,5)
	landCounter = 0.4
	running = true

	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		playBoost = -1
	end

	if(playMove == -1)then
		moveSound = SFX.PlaySound("ms_mech_move_lp",true)
		playMove = 1
	end	
end


function MSMech.OnJump()
	running = false
	SFX.PlaySound("ms_mech_jump")
	PlayAnimation(jumpDust, "jump")
	jumpCounter = 0.4
	Log("Jump!")

end

function MSMech.TouchUp()
	inputUp = true
end

function MSMech.TouchDown()
		inputUp = false
end

function MSMech.StartBoost()
	Log("StartBoost")
	if(playBoost == -1)then
		boostSound = SFX.PlaySound("ms_mech_boost_lp",true)
		playBoost = 1
	end

	if(playMove == 1)then
		SFX.StopSound(moveSound or -1)
		playMove = -1
	end	
end

function MSMech.StopBoost()
	Log("StopBoost")
	if(playBoost == 1)then
		SFX.StopSound(boostSound or -1)
		playBoost = -1
	end
end

function MSMech.FlameOn()
	Log("FlameOn")
end

function MSMech.FlameOff()
	Log("FlameOff")
	SFX.PlaySound("ms_mech_cool_down")
end

function MSMech.Explode()
	Log("Explode")

	SFX.PlaySound("ms_vehicle_explode")
end

function MSMech:OnDestroy()
	SFX.StopSound(boostSound or -1,0.1)
	SFX.StopSound(moveSound or 1,0.1)

	self.Base.OnDestroy(self)
end

RegisterVehicle("MSMech", "Mech", MSMech);
