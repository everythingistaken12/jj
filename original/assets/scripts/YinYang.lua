Log("YinYang Lua script started")

local YinYang = {}
local animationReset
local idleSound
local teleporterTimer
local headPos
local componentSound

function YinYang.ComponentComplete()
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

function YinYang.GetTextureList()
	return ""
end

function YinYang.ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("yinyang_teleporter_form_complete_01")
end


function YinYang:OnInit(info)
	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()
	animationReset = 0.0
	idleSound = -1
	teleporterTimer = 0.0
	SetLighteningOffset(15, 20)
end

function YinYang.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function YinYang.Ready(skipPickupSeq)
	Log("Ready")
	idleSound = SFX.PlaySound("yinyang_teleporter_lp",true)
end

function YinYang:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(teleporterTimer > 0.0)then
		teleporterTimer = teleporterTimer - dt
		if(teleporterTimer < 0.0)then
			teleporterTimer = 0.0
		end
	end	
end

function YinYang:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
end

function YinYang.HitRoof()
	Log("HitRoof")
end

function YinYang.HitGround()
	Log("HitGround")
end

function YinYang.TouchUp()

	Log("TouchUp")
	inputUp = true
end

function YinYang.TouchDown()
	Log("TouchDown")

	inputUp = false
end

function YinYang.TeleportOut()
	--if(teleporterTimer == 0)then
		SFX.PlaySound("yinyang_teleporter_teleport_01")
		--teleporterTimer = 0.4
	--end
	Log("Teleport Out")
end

function YinYang.TeleportIn()
	teleporterTimer = 0.2
	Log("Teleport In")
end

function YinYang.Explode()
	Log("Explode")
	
	SFX.StopSound(idleSound or -1,0.2)
	idleSound = -1
	SFX.PlaySound("yinyang_teleporter_explode_01")
	
	if(idleSound >= 0)then
		SFX.StopSound(idleSound or -1,0.2)
		idleSound = -1
	end
end

function YinYang:OnDestroy(didQuit)
	Log("Destroy")
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("YinYang", "Teleporter", YinYang);