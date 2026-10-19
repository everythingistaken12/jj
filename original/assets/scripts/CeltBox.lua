Log("CeltBox Lua script started")

local CeltBox = {}
local animationReset
local idleSound
local teleporterTimer
local headPos
local componentSound

function CeltBox.GetTextureList()
	return ""
end

function CeltBox:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function CeltBox.ComponentComplete()
	componentSound = math.random(3)

	if(componentSound == 1)then
		SFX.PlaySound("celtic_teleporter_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("celtic_teleporter_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("celtic_teleporter_form_3")
	end
	componentSound = 0
end

function CeltBox:ConstructionComplete()
	SFX.PlaySound("celtic_teleporter_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end


function CeltBox:OnInit(info)
	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()
	animationReset = 0.0
	idleSound = -1
	teleporterTimer = 0.0
	SetLighteningOffset(15, 20)

end

function CeltBox.PickupSequenceUpdate(dt)
end

function CeltBox:Ready(skipPickupSeq)
	idleSound = SFX.PlaySound("celtic_teleporter_lp",true)
	VehicleUtils.PlaySong(self, "music", "ready")
end

function CeltBox:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(teleporterTimer > 0.0)then
		teleporterTimer = teleporterTimer - dt
		if(teleporterTimer < 0.0)then
			teleporterTimer = 0.0
		end
	end
end

function CeltBox:OnDraw()
	self.Base.OnDraw(self)

	headPos = Vector.New(GetPlayerPosition())
end

function CeltBox.HitRoof()
end

function CeltBox.HitGround()
end

function CeltBox.TouchUp()

	inputUp = true
end

function CeltBox.TouchDown()

	inputUp = false
end

function CeltBox.TeleportOut()
	--if(teleporterTimer == 0)then
		SFX.PlaySound("celtic_teleporter_activate")
		--teleporterTimer = 0.4
	--end
end

function CeltBox.TeleportIn()
	teleporterTimer = 0.2
end

function CeltBox.Explode()

	SFX.StopSound(idleSound or -1,0.2)
	idleSound = -1
	SFX.PlaySound("celtic_teleporter_death")

	if(idleSound >= 0)then
		SFX.StopSound(idleSound or -1,0.2)
		idleSound = -1
	end
end

function CeltBox:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("CeltBox", "Teleporter", CeltBox);
