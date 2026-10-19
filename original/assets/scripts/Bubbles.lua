Log("Bubbles Lua script started")

local Bubbles = {}
local randomQuack
local randomLand
local quackTimer
local animationReset
local duckSlide
local duckSurface
local duckDive
local componentSound

function Bubbles.GetTextureList()
	return ""
end

function Bubbles:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	OverloadPickupSounds()

	quackTimer = 0.0
	animationReset = 0.0
	duckSlide = -1
	duckSurface = -1
	duckDive = -1
	componentSound = 0.0
end

function Bubbles:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Bubbles.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function Bubbles.ComponentComplete()
	Log("Component!")
	componentSound = math.random(3)
	Log("randomQuack = "..componentSound)

	if(componentSound == 1)then
		SFX.PlaySound("duck_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("duck_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("duck_form_3")	
	end
	componentSound = 0
end

function Bubbles:ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("duck_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function Bubbles:Ready(skipPickupSeq)
	Log("Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
end

function Bubbles:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(quackTimer > 0.0)then
		quackTimer = quackTimer - dt
		if(quackTimer < 0.0)then
			quackTimer = 0.0
			BubblesQuack(0)
		end
	end
	
	if(animationReset > 0.0)then
		animationReset = animationReset - dt
		if(animationReset < 0.0)then
			animationReset = 0.0
			PlayAnimation(-1, "idle")
		end
	end
end

function Bubbles.HitGround()
	if(duckSlide == -1)then
		duckSlide = SFX.PlaySound("duck_slide_lp", true)
	end
	Log("HitGround")
end

function Bubbles.LeaveGround()
	SFX.StopSound(duckSlide or -1,0.2)
	duckSlide = -1
	Log("LeaveGround")
end

function Bubbles.Dive()
	SFX.StopSound(duckSurface or -1,0.2)
	duckSurface = -1
	if(duckDive == -1)then
		duckDive = SFX.PlaySound("duck_underwater_lp", true)
	end
	Log("Dive")
end

function Bubbles.Surface()
	SFX.StopSound(duckDive or -1,0.2)
	duckDive = -1
	if(duckSurface == -1)then
		duckSurface = SFX.PlaySound("duck_surface_lp", true)
	end
	SFX.PlaySound("duck_jump")
	Log("Surface")
end

function Bubbles.Airbourne()
	SFX.StopSound(duckSurface or -1,0.2)
	duckSurface = -1
	SFX.StopSound(duckDive or -1,0.2)
	duckDive = -1
	SFX.PlaySound("duck_jump")
	quackTimer = 0.1
	Log("Airbourne")
end

function Bubbles.HitWater()
	if(duckSurface == -1)then
		duckSurface = SFX.PlaySound("duck_surface_lp", true)
	end
	Log("duckSurface = "..duckSurface)
	
	randomLand = math.random(4)
	if(randomLand == 1)then
		SFX.PlaySound("duck_land")
	elseif(randomLand == 2)then
		SFX.PlaySound("duck_land_1")
	elseif(randomLand == 3)then
		SFX.PlaySound("duck_land_2")
	elseif(randomLand == 4)then
		SFX.PlaySound("duck_land_3")
	end
	
	randomLand = 0
	
	Log("HitWater")
end

function Bubbles.TouchUp()
	inputUp = true
end

function Bubbles.TouchDown()
	inputUp = false
end

function Bubbles.Explode()
	SFX.PlaySound("duck_explode")
	SFX.PlaySound("duck_impact")
	SFX.StopSound(duckDive or -1,0.2)
	duckDive = -1
	SFX.StopSound(duckSlide or -1,0.2)
	duckSlide = -1
	SFX.StopSound(duckSurface or -1,0.2)
	duckSurface = -1
	Log("Explode")
end

function Bubbles:OnDestroy()
	Log("OnDestroy")

	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function BubblesQuack(a)
	randomQuack = math.random(10)
	Log("randomQuack = "..randomQuack)

	if(a == 0)then
		if(randomQuack == 1)then
			PlayAnimation(-1, "quack")
			SFX.PlaySound("duck_vox_1")
			animationReset = 0.5
		elseif(randomQuack == 2)then
			PlayAnimation(-1, "quack")
			SFX.PlaySound("duck_vox_2")
			animationReset = 0.5
		elseif(randomQuack == 3)then
			PlayAnimation(-1, "quack")
			SFX.PlaySound("duck_vox_3")	
			animationReset = 0.5
		elseif(randomQuack == 4)then
			PlayAnimation(-1, "quack")
			SFX.PlaySound("duck_vox_4")
			animationReset = 0.5
		elseif(randomQuack == 5)then
			PlayAnimation(-1, "quack")
			SFX.PlaySound("duck_vox_5")	
			animationReset = 0.5
		elseif(randomQuack == 6)then
			PlayAnimation(-1, "quack")
			SFX.PlaySound("duck_vox_6")
			animationReset = 0.5
		end
	elseif(a == 1)then
		PlayAnimation(-1, "quack_long")
		SFX.PlaySound("duck_form_complete")
		animationReset = 1.0
	end


	randomQuack = 0
end

RegisterVehicle("Bubbles", "JetSki", Bubbles);