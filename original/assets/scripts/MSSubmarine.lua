Log("MSSubmarine Lua script started")

local MSSubmarine = {}

local randomLand
local randomSurface

local animationReset
local submarineSlide
local submarineSurface
local submarineDive
local componentSound


function MSSubmarine:OnInit(info)
	self.Base.OnInit(self, info)

	self:SetDrawHead(true)

	SetDrawOffset(30,50)	

	OverloadVehicleSounds()

	animationReset = 0.0
	submarineSlide = -1
	submarineSurface = -1
	submarineDive = -1
	componentSound = 0.0
end

function MSSubmarine.PickupSequenceUpdate(dt)
end

function MSSubmarine.ComponentComplete()
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


function MSSubmarine.ConstructionComplete()
	SFX.PlaySound("ms_vehicle_form_complete")

	Log("MSSubmarine Lua: vehicle ConstructionComplete")
end

function MSSubmarine.Ready(skipPickupSeq)
end

function MSSubmarine:OnDestroy(didQuit)
	self.Base.OnDestroy(self)
	--SFX.SetLevelSong("default")
	if(IsEventActive() == false) then
		SFX.PlaySong("default", 0.5)
	end
	Log("MSSubmarine Lua: vehicle destroy")

end

function MSSubmarine:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function MSSubmarine.HitGround()
	if(submarineSlide == -1)then
		submarineSlide = SFX.PlaySound("ms_sub_slide_lp", true)
	end
end

function MSSubmarine.LeaveGround()
	SFX.StopSound(submarineSlide or -1,0.2)
	submarineSlide = -1
end

function MSSubmarine.Dive()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	if(submarineDive == -1)then
		submarineDive = SFX.PlaySound("ms_sub_water_lp", true)
	end
end

function MSSubmarine.Surface()
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("ms_sub_surface_lp", true)
	end
end

function MSSubmarine.Airbourne()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1

	randomSurface = math.random(3)
	if(randomSurface == 1)then
		SFX.PlaySound("ms_sub_water_exit_01")
	elseif(randomSurface == 2)then
		SFX.PlaySound("ms_sub_water_exit_02")
	elseif(randomSurface == 3)then
		SFX.PlaySound("ms_sub_water_exit_03")
	end
end

function MSSubmarine.HitWater()
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("ms_sub_surface_lp", true)
	end

	randomLand = math.random(3)
	if(randomLand == 1)then
		SFX.PlaySound("ski_land_01")
	elseif(randomLand == 2)then
		SFX.PlaySound("ski_land_02")
	elseif(randomLand == 3)then
		SFX.PlaySound("ski_land_03")
	end

	randomLand = 0

end

function MSSubmarine.TouchUp()
	inputUp = true
end

function MSSubmarine.TouchDown()
	inputUp = false
end

function MSSubmarine.Explode()
	SFX.PlaySound("ms_vehicle_explode")
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


RegisterVehicle("MSSubmarine", "JetSki", MSSubmarine);
