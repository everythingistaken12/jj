Log("EasterEgg Lua script started")

local EasterEgg = {}
local animationReset
local idleSound
local teleporterTimer
local backWindow
local headPos
local componentSound

function EasterEgg.GetTextureList()
	return "textures/Characters/Vehicles/Teleporter/EasterEgg/teleporterback.tex|textures/Characters/Vehicles/Teleporter/EasterEgg/vehicleTeleporter.tex"
end

function EasterEgg.ComponentComplete()
	Log("Component!")
	componentSound = math.random(3)
	Log("randomQuack = "..componentSound)

	if(componentSound == 1)then
		SFX.PlaySound("easter_teleporter_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("easter_teleporter_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("easter_teleporter_form_3")	
	end
	componentSound = 0
end

function EasterEgg.ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("easter_teleporter_form_complete")
end


function EasterEgg:OnInit(info)
	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()
	animationReset = 0.0
	idleSound = -1
	teleporterTimer = 0.0
	backWindow = LoadTexture("textures/Characters/Vehicles/Teleporter/EasterEgg/teleporterback.xml", 9)
	Log("backWindow Init ="..backWindow)
	SetLighteningOffset(15, 20)
end

function EasterEgg.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function EasterEgg.Ready(skipPickupSeq)
	Log("Ready")
	idleSound = SFX.PlaySound("easter_teleporter_lp",true)
	PlayAnimation(backWindow, "idle")
end

function EasterEgg:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(teleporterTimer > 0.0)then
		teleporterTimer = teleporterTimer - dt
		if(teleporterTimer < 0.0)then
			teleporterTimer = 0.0
			PlayAnimation(backWindow, "idle")
		end
	end	
end

function EasterEgg:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
	DrawTexture(backWindow, headPos[1], headPos[2] + 12)
end

function EasterEgg.HitRoof()
	Log("HitRoof")
end

function EasterEgg.HitGround()
	Log("HitGround")
end

function EasterEgg.TouchUp()

	Log("TouchUp")
	inputUp = true
end

function EasterEgg.TouchDown()
	Log("TouchDown")

	inputUp = false
end

function EasterEgg.TeleportOut()
	--if(teleporterTimer == 0)then
		SFX.PlaySound("easter_teleporter_activate")
		--teleporterTimer = 0.4
		PlayAnimation(backWindow, "teleport_out")
		Log("backWindow TouchDown ="..backWindow)
	--end
	Log("Teleport Out")
end

function EasterEgg.TeleportIn()
	PlayAnimation(backWindow, "teleport_in")
	teleporterTimer = 0.2
	Log("Teleport In")
end

function EasterEgg.Explode()
	Log("Explode")
	
	SFX.StopSound(idleSound or -1,0.2)
	idleSound = -1
	SFX.PlaySound("easter_teleporter_death")
	
	if(idleSound >= 0)then
		SFX.StopSound(idleSound or -1,0.2)
		idleSound = -1
	end
end

function EasterEgg:OnDestroy(didQuit)
	Log("Destroy")
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("EasterEgg", "Teleporter", EasterEgg);