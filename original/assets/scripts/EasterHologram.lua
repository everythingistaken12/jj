Log("EasterHologram Lua script started")

local EasterHologram = {}

local randomLand
local randomSurface

local animationReset
local submarineSlide
local submarineSurface
local submarineDive
local componentSound
local hologram

function EasterHologram.GetTextureList()
	return "textures/Characters/Vehicles/JetSki/EasterHologram/hologram.tex"
end

function EasterHologram:OnInit(info)

	self.Base.OnInit(self, info)

	OverloadVehicleSounds()
	OverloadPickupSounds()

	hologram = LoadTexture("textures/Characters/Vehicles/Jetski/EasterHologram/hologram.xml", 10)	

	animationReset = 0.0
	submarineSlide = -1
	submarineSurface = -1
	submarineDive = -1
	componentSound = 0.0
end

function EasterHologram.PickupSequenceUpdate(dt)
end

function EasterHologram.ComponentComplete()
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


function EasterHologram.ConstructionComplete()
	SFX.PlaySound("jetski_easter_hologram_form_complete")

	Log("EasterHologram Lua: vehicle ConstructionComplete")
end

function EasterHologram.Ready(skipPickupSeq)
end

function EasterHologram:OnDestroy(didQuit)
	self.Base.OnDestroy(self)
	--SFX.SetLevelSong("default")
	if(IsEventActive() == false) then
		SFX.PlaySong("default", 0.5)
	end
	Log("EasterHologram Lua: vehicle destroy")

end

function EasterHologram:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function EasterHologram:OnDraw()
	self.Base.OnDraw(self)
	
	local rotation = GetVehicleRotation()
	headPos = Vector.New(GetPlayerPosition())
	if(submarineDive == -1)then
		DrawTexture(hologram, headPos[1], headPos[2] - 15, -rotation)
	end
	
end

function EasterHologram.HitGround()
	if(submarineSlide == -1)then
		submarineSlide = SFX.PlaySound("jetski_easter_hologram_slide_lp", true)
	end
end

function EasterHologram.LeaveGround()
	SFX.StopSound(submarineSlide or -1,0.2)
	submarineSlide = -1
end

function EasterHologram.Dive()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	if(submarineDive == -1)then
		submarineDive = SFX.PlaySound("jetski_easter_hologram_water_lp", true)
	end
end

function EasterHologram.Surface()
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("jetski_easter_hologram_surface_lp", true)
	end
	
end

function EasterHologram.Airbourne()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1

	randomSurface = math.random(3)
	if(randomSurface == 1)then
		SFX.PlaySound("jetski_easter_hologram_water_exit_01")
	elseif(randomSurface == 2)then
		SFX.PlaySound("jetski_easter_hologram_water_exit_02")
	elseif(randomSurface == 3)then
		SFX.PlaySound("jetski_easter_hologram_water_exit_03")
	end
end

function EasterHologram.HitWater()
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("jetski_easter_hologram_surface_lp", true)
	end

	randomLand = math.random(3)
	if(randomLand == 1)then
		SFX.PlaySound("jetski_easter_hologram_land_01")
	elseif(randomLand == 2)then
		SFX.PlaySound("jetski_easter_hologram_land_02")
	elseif(randomLand == 3)then
		SFX.PlaySound("jetski_easter_hologram_land_03")
	end

	randomLand = 0

end

function EasterHologram.TouchUp()
	inputUp = true
end

function EasterHologram.TouchDown()
	inputUp = false
end

function EasterHologram.Explode()
	SFX.PlaySound("jetski_easter_hologram_explode")
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1
	SFX.StopSound(submarineSlide or -1,0.2)
	submarineSlide = -1
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end


RegisterVehicle("EasterHologram", "JetSki", EasterHologram);
