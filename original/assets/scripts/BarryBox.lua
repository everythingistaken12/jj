Log("BarryBox Lua script started")

local BarryBox = {}
local animationReset
local idleSound
local teleporterTimer
local backWindow
local headPos
local componentSound

function BarryBox.GetTextureList()
	return "textures/Characters/Vehicles/Teleporter/Barrybox/teleporterWindows.tex|textures/Characters/Vehicles/Components/Teleporter/BarryBox/ComponentBacking.tex"
end

function BarryBox:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function BarryBox.ComponentComplete()
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

function BarryBox:ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("box_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end


function BarryBox:OnInit(info)
	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()
	animationReset = 0.0
	idleSound = -1
	teleporterTimer = 0.0
	backWindow = LoadTexture("textures/Characters/Vehicles/Teleporter/BarryBox/TeleporterWindows.xml", 9)
	Log("backWindow Init ="..backWindow)
	SetLighteningOffset(15, 20)
	AddPickupComponent("textures/Characters/Vehicles/Components/Teleporter/BarryBox/ComponentBacking.tex", 9, -1)
end

function BarryBox.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function BarryBox:Ready(skipPickupSeq)
	Log("Ready")
	idleSound = SFX.PlaySound("box_lp",true)
	PlayAnimation(backWindow, "idle")
	VehicleUtils.PlaySong(self, "music", "ready")
end

function BarryBox:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(teleporterTimer > 0.0)then
		teleporterTimer = teleporterTimer - dt
		if(teleporterTimer < 0.0)then
			teleporterTimer = 0.0
			PlayAnimation(backWindow, "idle")
		end
	end	
end

function BarryBox:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
	DrawTexture(backWindow, headPos[1] + 1, headPos[2] + 15)
end

function BarryBox.HitRoof()
	Log("HitRoof")
end

function BarryBox.HitGround()
	Log("HitGround")
end

function BarryBox.TouchUp()

	Log("TouchUp")
	inputUp = true
end

function BarryBox.TouchDown()
	Log("TouchDown")

	inputUp = false
end

function BarryBox.TeleportOut()
	--if(teleporterTimer == 0)then
		SFX.PlaySound("box_activate")
		--teleporterTimer = 0.4
		PlayAnimation(backWindow, "teleport_out")
		Log("backWindow TouchDown ="..backWindow)
	--end
	Log("Teleport Out")
end

function BarryBox.TeleportIn()
	PlayAnimation(backWindow, "teleport_in")
	teleporterTimer = 0.2
	Log("Teleport In")
end

function BarryBox.Explode()
	Log("Explode")
	
	SFX.StopSound(idleSound or -1,0.2)
	idleSound = -1
	SFX.PlaySound("box_explode")
	
	if(idleSound >= 0)then
		SFX.StopSound(idleSound or -1,0.2)
		idleSound = -1
	end
end

function BarryBox:OnDestroy()
	Log("Destroy")
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)

end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("BarryBox", "Teleporter", BarryBox);