Log("StarTrekTeleporter Lua script started")

local StarTrekTeleporter = {}
local animationReset
local idleSound
local teleporterTimer
local headPos
local componentSound

function StarTrekTeleporter.ComponentComplete()
	Log("Component!")
	componentSound = math.random(3)
	Log("randomQuack = "..componentSound)

	if(componentSound == 1)then
		SFX.PlaySound("vehicle_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("vehicle_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("vehicle_form_3")	
	end
	componentSound = 0
end

function StarTrekTeleporter.GetTextureList()
	return ""
end

function StarTrekTeleporter.ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("st_transporter_form_complete")
end


function StarTrekTeleporter:OnInit(info)
	local auxParams = { idleAnimation="ANIM_SHOOT", drawPlayerOnTop="true", drawPlayerDuringSequence="true" }
	self.Base.OnInit(self, info, auxParams)

	OverloadVehicleSounds()
	OverloadPickupSounds()
	animationReset = 0.0
	idleSound = -1
	teleporterTimer = 0.0
	SetLighteningOffset(15, 20)
end

function StarTrekTeleporter.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function StarTrekTeleporter.Ready(skipPickupSeq)
	Log("Ready")
	idleSound = SFX.PlaySound("st_transporter_lp",true)
end

function StarTrekTeleporter:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(teleporterTimer > 0.0)then
		teleporterTimer = teleporterTimer - dt
		if(teleporterTimer < 0.0)then
			teleporterTimer = 0.0
		end
	end	
end

function StarTrekTeleporter:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
end

function StarTrekTeleporter.HitRoof()
	Log("HitRoof")
end

function StarTrekTeleporter.HitGround()
	Log("HitGround")
end

function StarTrekTeleporter.TouchUp()

	Log("TouchUp")
	inputUp = true
end

function StarTrekTeleporter.TouchDown()
	Log("TouchDown")

	inputUp = false
end

function StarTrekTeleporter.TeleportOut()
	--if(teleporterTimer == 0)then
		SFX.PlaySound("st_transporter_activate")
		--teleporterTimer = 0.4
	--end
	Log("Teleport Out")
end

function StarTrekTeleporter.TeleportIn()
	teleporterTimer = 0.2
	Log("Teleport In")
end

function StarTrekTeleporter.Explode()
	Log("Explode")
	
	SFX.StopSound(idleSound or -1,0.2)
	idleSound = -1
	SFX.PlaySound("st_transporter_explode")
	
	if(idleSound >= 0)then
		SFX.StopSound(idleSound or -1,0.2)
		idleSound = -1
	end
end

function StarTrekTeleporter:OnDestroy(didQuit)
	Log("Destroy")
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("StarTrekTeleporter", "Teleporter", StarTrekTeleporter);