Log("YellowSubmarine Lua script started")

local YellowSubmarine = {}

local randomLand
local randomSurface

local animationReset
local submarineSlide
local submarineSurface
local submarineDive

function YellowSubmarine:OnInit(info)
	self.Base.OnInit(self, info)

	self:SetDrawHead(true)

	OverloadVehicleSounds()

	animationReset = 0.0
	submarineSlide = -1
	submarineSurface = -1
	submarineDive = -1
end

function YellowSubmarine.PickupSequenceUpdate(dt)
end

function YellowSubmarine.ComponentComplete()
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


function YellowSubmarine.ConstructionComplete()
	SFX.PlaySound("vehicle_form_complete")

	Log("YellowSubmarine Lua: vehicle ConstructionComplete")
end

function YellowSubmarine.Ready(skipPickupSeq)
end

function YellowSubmarine:OnDestroy(didQuit)
	self.Base.OnDestroy(self)

	Log("YellowSubmarine Lua: vehicle destroy")

end

function YellowSubmarine:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function YellowSubmarine.HitGround()
	if(submarineSlide == -1)then
		submarineSlide = SFX.PlaySound("ms_sub_slide_lp", true)
	end
end

function YellowSubmarine.LeaveGround()
	SFX.StopSound(submarineSlide or -1,0.2)
	submarineSlide = -1
end

function YellowSubmarine.Dive()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	if(submarineDive == -1)then
		submarineDive = SFX.PlaySound("ms_sub_water_lp", true)
	end
end

function YellowSubmarine.Surface()
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("ms_sub_surface_lp", true)
	end
end

function YellowSubmarine.Airbourne()
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

function YellowSubmarine.HitWater()
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

function YellowSubmarine.TouchUp()
	inputUp = true
end

function YellowSubmarine.TouchDown()
	inputUp = false
end

function YellowSubmarine.Explode()
	SFX.PlaySound("mech_explode")
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


RegisterVehicle("YellowSubmarine", "JetSki", YellowSubmarine);
