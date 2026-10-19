Log("TMNTJetski Lua script started")

local TMNTJetski = {}

local randomLand
local randomSurface

local animationReset
local submarineSlide
local submarineSurface
local submarineDive
local componentSound


function TMNTJetski:OnInit(info)
	local auxParams = { idleAnimation="ANIM_BOUNCE", drawPlayerOnTop="true", idleFrame="1", idleHeadAnimation="ANIM_SHOOT", idleHeadFrame="1",
		spray_emitter = "Surfboard_Water_Spray_1",
		spray_air_emitter = "Surfboard_Water_Spray_air",
		bubbles_emitter = "Surfboard_Jetski_Bubbles",
		splash_emitter = "Surfboard_Water_Splash"
	}

	self.Base.OnInit(self, info, auxParams)

	SetDrawOffset(30, 50)
	SetWaterColour(0.271, 0.741, 0.235, 1.0)
	SetJetskiRobotDogSettings("Surfboard_Water_skim", "GoldSparkle_Surfboard", "Surfboard_Water_Spray_small")

	OverloadVehicleSounds()
	OverloadPickupSounds()

	animationReset = 0.0
	submarineSlide = -1
	submarineSurface = -1
	submarineDive = -1
	componentSound = 0.0
end

function TMNTJetski.PickupSequenceUpdate(dt)
end

function TMNTJetski.ComponentComplete()
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


function TMNTJetski.ConstructionComplete()
	SFX.PlaySound("tmnt_sewersurfer_form_complete")

	Log("TMNTJetski Lua: vehicle ConstructionComplete")
end

function TMNTJetski.Ready(skipPickupSeq)
end

function TMNTJetski:OnDestroy(didQuit)
	self.Base.OnDestroy(self)
	--SFX.SetLevelSong("default")
	if(IsEventActive() == false) then
		SFX.PlaySong("default", 0.5)
	end
	Log("TMNTJetski Lua: vehicle destroy")

end

function TMNTJetski:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)

	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function TMNTJetski.HitGround()
	if(submarineSlide == -1)then
		submarineSlide = SFX.PlaySound("tmnt_sewersurfer_slide_lp", true)
	end
end

function TMNTJetski.LeaveGround()
	SFX.StopSound(submarineSlide or -1,0.2)
	submarineSlide = -1
end

function TMNTJetski.Dive()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	if(submarineDive == -1)then
		submarineDive = SFX.PlaySound("tmnt_sewersurfer_water_lp", true)
	end
end

function TMNTJetski.Surface()
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("tmnt_sewersurfer_surface_lp", true)
	end
end

function TMNTJetski.Airbourne()
	SFX.StopSound(submarineSurface or -1,0.2)
	submarineSurface = -1
	SFX.StopSound(submarineDive or -1,0.2)
	submarineDive = -1

	randomSurface = math.random(3)
	if(randomSurface == 1)then
		SFX.PlaySound("tmnt_sewersurfer_water_exit_01")
	elseif(randomSurface == 2)then
		SFX.PlaySound("tmnt_sewersurfer_water_exit_02")
	elseif(randomSurface == 3)then
		SFX.PlaySound("tmnt_sewersurfer_water_exit_03")
	end
end

function TMNTJetski.HitWater()
	if(submarineSurface == -1)then
		submarineSurface = SFX.PlaySound("tmnt_sewersurfer_surface_lp", true)
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

function TMNTJetski.TouchUp()
	inputUp = true
end

function TMNTJetski.TouchDown()
	inputUp = false
end

function TMNTJetski.Explode()
	SFX.PlaySound("tmnt_sewersurfer_explode")
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


RegisterVehicle("TMNTJetski", "JetSki", TMNTJetski);
