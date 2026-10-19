Log("FrankensteinTeleporter Lua script started")

local FrankensteinTeleporter = {}
local animationReset
local idleSound
local teleporterTimer
local headPos
local componentSound

function FrankensteinTeleporter.ComponentComplete()
	Log("Component!")
	componentSound = math.random(3)
	Log("randomQuack = "..componentSound)

	if(componentSound == 1)then
		SFX.PlaySound("frankenstein_teleporter_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("frankenstein_teleporter_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("frankenstein_teleporter_form_3")	
	end
	componentSound = 0
end

function FrankensteinTeleporter.GetTextureList()
	return ""
end

function FrankensteinTeleporter.ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("frankenstein_teleporter_form_complete")
end


function FrankensteinTeleporter:OnInit(info)
	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()
	animationReset = 0.0
	idleSound = -1
	teleporterTimer = 0.0
	SetLighteningOffset(15, 10)
end

function FrankensteinTeleporter.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function FrankensteinTeleporter.Ready(skipPickupSeq)
	Log("Ready")
	idleSound = SFX.PlaySound("frankenstein_teleporter_lp",true)
end

function FrankensteinTeleporter:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(teleporterTimer > 0.0)then
		teleporterTimer = teleporterTimer - dt
		if(teleporterTimer < 0.0)then
			teleporterTimer = 0.0
		end
	end	
end

function FrankensteinTeleporter:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
end

function FrankensteinTeleporter.HitRoof()
	Log("HitRoof")
end

function FrankensteinTeleporter.HitGround()
	Log("HitGround")
end

function FrankensteinTeleporter.TouchUp()

	Log("TouchUp")
	inputUp = true
end

function FrankensteinTeleporter.TouchDown()
	Log("TouchDown")

	inputUp = false
end

function FrankensteinTeleporter.TeleportOut()
	--if(teleporterTimer == 0)then
		SFX.PlaySound("frankenstein_teleporter_activate")
		--teleporterTimer = 0.4
	--end
	Log("Teleport Out")
end

function FrankensteinTeleporter.TeleportIn()
	teleporterTimer = 0.2
	Log("Teleport In")
end

function FrankensteinTeleporter.Explode()
	Log("Explode")
	
	SFX.StopSound(idleSound or -1,0.2)
	idleSound = -1
	SFX.PlaySound("frankenstein_teleporter_death")
	
	if(idleSound >= 0)then
		SFX.StopSound(idleSound or -1,0.2)
		idleSound = -1
	end
end

function FrankensteinTeleporter:OnDestroy(didQuit)
	Log("Destroy")
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("FrankensteinTeleporter", "Teleporter", FrankensteinTeleporter);