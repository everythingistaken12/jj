Log("BrazenBarnacle Lua script started")

local BrazenBarnacle = {}

local randomLand
local randomSurface

local animationReset
local pirateShipSlide
local pirateShipSurface
local pirateShipDive
local componentSound

function BrazenBarnacle.GetTextureList()
	return "textures/Characters/Vehicles/JetSki/BrazenBarnacle/handle.tex"
end

function BrazenBarnacle:OnInit(info)
	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()

	animationReset = 0.0
	pirateShipSlide = -1
	pirateShipSurface = -1
	pirateShipDive = -1
	componentSound = 0.0
end

function BrazenBarnacle:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function BrazenBarnacle.PickupSequenceUpdate(dt)
end

function BrazenBarnacle.ComponentComplete()
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


function BrazenBarnacle:ConstructionComplete()
	SFX.PlaySound("pirate_collect")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
	Log("pirate ship Lua: vehicle ConstructionComplete")
end

function BrazenBarnacle:Ready(skipPickupSeq)
	if (IsEventActive() == false) then
		VehicleUtils.PlaySong(self, "music", "ready")
		Log("pirate ship Lua: playing song ")
	end
end

function BrazenBarnacle:OnDestroy()
	local outroPlayed = false

	if (IsEventActive() == false) then
		outroPlayed = VehicleUtils.PlayOutro(self)
	end

	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)

	Log("pirate ship Lua: vehicle destroy")
end

function BrazenBarnacle:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function BrazenBarnacle.HitGround()
	if(pirateShipSlide == -1)then
		pirateShipSlide = SFX.PlaySound("bird_slideLP", true)
	end
end

function BrazenBarnacle.LeaveGround()
	SFX.StopSound(pirateShipSlide or -1,0.2)
	pirateShipSlide = -1
end

function BrazenBarnacle.Dive()
	SFX.StopSound(pirateShipSurface or -1,0.2)
	pirateShipSurface = -1
	if(pirateShipDive == -1)then
		pirateShipDive = SFX.PlaySound("pirate_water_lp", true)
	end
end

function BrazenBarnacle.Surface()
	SFX.StopSound(pirateShipDive or -1,0.2)
	pirateShipDive = -1
	if(pirateShipSurface == -1)then
		pirateShipSurface = SFX.PlaySound("pirate_surface_lp", true)
	end
end

function BrazenBarnacle.Airbourne()
	SFX.StopSound(pirateShipSurface or -1,0.2)
	pirateShipSurface = -1
	SFX.StopSound(pirateShipDive or -1,0.2)
	pirateShipDive = -1

	randomSurface = math.random(3)
	if(randomSurface == 1)then
		SFX.PlaySound("pirate_water_exit_01")
	elseif(randomSurface == 2)then
		SFX.PlaySound("pirate_water_exit_02")
	elseif(randomSurface == 3)then
		SFX.PlaySound("pirate_water_exit_03")
	end
end

function BrazenBarnacle.HitWater()
	if(pirateShipSurface == -1)then
		pirateShipSurface = SFX.PlaySound("pirate_surface_lp", true)
	end

	randomLand = math.random(3)
	if(randomLand == 1)then
		SFX.PlaySound("pirate_land_01")
	elseif(randomLand == 2)then
		SFX.PlaySound("pirate_land_02")
	elseif(randomLand == 3)then
		SFX.PlaySound("pirate_land_03")
	end

	randomLand = 0

end

function BrazenBarnacle.TouchUp()
	inputUp = true
end

function BrazenBarnacle.TouchDown()
	inputUp = false
end

function BrazenBarnacle.Explode()
	SFX.PlaySound("pirate_death")
	SFX.StopSound(pirateShipDive or -1,0.2)
	pirateShipDive = -1
	SFX.StopSound(pirateShipSlide or -1,0.2)
	pirateShipSlide = -1
	SFX.StopSound(pirateShipSurface or -1,0.2)
	pirateShipSurface = -1
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end


RegisterVehicle("BrazenBarnacle", "JetSki", BrazenBarnacle);
