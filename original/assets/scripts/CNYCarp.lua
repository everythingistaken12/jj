Log("CNYCarp Lua script started")

local CNYCarp = {}

local randomLand
local randomSurface

local animationReset
local submarineSlide
local submarineSurface
local submarineDive
local componentSound
local goldSparkles
local headPos



function CNYCarp:OnInit(info)
	local auxParams = { drawPlayerOnTop="true", drawPlayerDuringSequence="true" }
	self.Base.OnInit(self, info, auxParams)
	
	OverloadVehicleSounds()

	animationReset = 0.0
	submarineSlide = -1
	submarineSurface = -1
	submarineDive = -1
	componentSound = 0.0
	goldSparkles = CreateParticle("GoldSparkle_Mech")
	SetParticleEnabled(goldSparkles, false)			
end

function CNYCarp.PickupSequenceUpdate(dt)
end

function CNYCarp.ComponentComplete()
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


function CNYCarp.ConstructionComplete()
	SFX.PlaySound("carp_sub_form_complete")

	Log("CNYCarp Lua: vehicle ConstructionComplete")
end

function CNYCarp.Ready(skipPickupSeq)
	SetParticleEnabled(goldSparkles, true)	
end

function CNYCarp:OnDestroy(didQuit)
	self.Base.OnDestroy(self)
	--SFX.SetLevelSong("default")
	if(IsEventActive() == false) then
		SFX.PlaySong("default", 0.5)
	end
	Log("CNYCarp Lua: vehicle destroy")

end

function CNYCarp:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())

	sparklesPos = headPos + Vector.New(5.0, -4.0)
	worldPos = Vector.New(Level.GetOffset())
	finalSparklesPos = sparklesPos - worldPos		

	SetParticlePosition(goldSparkles, finalSparklesPos[1] - 7, finalSparklesPos[2])		

end

function CNYCarp:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function CNYCarp.HitGround()
	if(submarineSlide == -1)then
		submarineSlide = SFX.PlaySound("carp_sub_slide_lp", true)
	end
end

function CNYCarp.LeaveGround()
	SFX.StopSound(submarineSlide or -1,0.2)
	submarineSlide = -1
end

function CNYCarp.Dive()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	if(submarineDive == -1)then
		submarineDive = SFX.PlaySound("carp_sub_water_lp", true)
	end
end

function CNYCarp.Surface()
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("carp_sub_surface_lp", true)
	end
end

function CNYCarp.Airbourne()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1

	randomSurface = math.random(3)
	if(randomSurface == 1)then
		SFX.PlaySound("carp_sub_water_exit_01")
	elseif(randomSurface == 2)then
		SFX.PlaySound("carp_sub_water_exit_02")
	elseif(randomSurface == 3)then
		SFX.PlaySound("carp_sub_water_exit_03")
	end
end

function CNYCarp.HitWater()
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("carp_sub_surface_lp", true)
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

function CNYCarp.TouchUp()
	inputUp = true
end

function CNYCarp.TouchDown()
	inputUp = false
end

function CNYCarp.Explode()
	SFX.PlaySound("carp_sub_explode")
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


RegisterVehicle("CNYCarp", "JetSki", CNYCarp);
