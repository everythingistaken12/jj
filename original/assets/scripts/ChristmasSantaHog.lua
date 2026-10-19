Log("ChristmasSantaHog Lua script started")

local ChristmasSantaHog = {}
local gunBlast
local wheelieDust
local jumpCounter = 0.0
local jumpMove = 0.0
local landMove = 0.0
local landCounter = 0.0
local gunBlastCounter = 0.0
local wheelieDustCounter = 0.0
local onGround = false
local wheelie = false
local shootGun = false
local groundSound = -1
local fireworks


local headPos

function ChristmasSantaHog.GetTextureList()
	return "textures/Characters/Vehicles/Hog/ChristmasSantaHog/effect_fireworkGun.tex"
end

function ChristmasSantaHog.GetConstructionRenderFlags(phase)
	return -1
end

function ChristmasSantaHog.ComponentComplete()

end

function ChristmasSantaHog:ConstructionComplete()
	VehicleUtils.PlaySong(self, "music", "construction_complete")
	SFX.PlaySound("santa_hog_form_complete")
	Log("Construction!")
end

function ChristmasSantaHog:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function ChristmasSantaHog:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	onGround = false
	groundSound = -1
	SetHogEffects(false)
	gunBlast = LoadTexture("textures/Characters/Vehicles/Hog/ChristmasSantaHog/effect_fireworkGun.xml", 10)
	fireworks = LoadTexture("textures/Effects/effect_fireworks.xml", 20)
	Log("Init Particles!")
end

function ChristmasSantaHog:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
	Log("Ready")
end

function ChristmasSantaHog:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(jumpCounter > 0.0)then
		jumpCounter = jumpCounter - dt
		jumpMove = jumpMove + 3		
	end	
	if(landCounter > 0.0)then
		landCounter = landCounter - dt
		landMove = landMove + 3
	end
	if(gunBlastCounter > 0.0)then
		gunBlastCounter = gunBlastCounter - dt
	end
	if(wheelieDustCounter > 0.0)then
		wheelieDustCounter = wheelieDustCounter - dt
	end
	--Log("Wheelie = "..tostring(wheelie))
	
	--Log("onGround = "..tostring(onGround))
	anim, frame = GetAnimationFrame(-1)
	if(wheelie == true and frame == 6)then
		--onGround = true
		if(groundSound == -1)then
			Log("Play Hover Engine Initially")
			groundSound = SFX.PlaySound("dullahan_bike_engine_lp",true)
		end
		wheelie = false
	end
end

function ChristmasSantaHog:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())

	worldPos = Vector.New(Level.GetOffset())

	if(gunBlastCounter > 0.0)then
		DrawTexture(gunBlast, headPos[1] + 35, headPos[2]  + 15)
		DrawTexture(fireworks, headPos[1] + 85, headPos[2]  + 15)
	end
	if(wheelieDustCounter > 0.0)then
		DrawTexture(wheelieDust, headPos[1] - 55, headPos[2]  + 10)
	end
end


function ChristmasSantaHog.ShootGun()
	Log("Shoot Gun")
	PlayAnimation(gunBlast, "fire")
	PlayAnimation(fireworks, "fire")
	shootSound = math.random(4)
	if(shootSound == 1)then
		SFX.PlaySound("santa_hog_candycane_fire_01")
	elseif(shootSound == 2)then
		SFX.PlaySound("santa_hog_candycane_fire_02")
	elseif(shootSound == 3)then
		SFX.PlaySound("santa_hog_candycane_fire_03")
	elseif(shootSound == 4)then
		SFX.PlaySound("santa_hog_candycane_fire_04")
	end
	gunBlastCounter = 0.3
	shootGun = true
end

function ChristmasSantaHog.HitGround()
	landCounter = 0.4
	landMove = 0.0
	SFX.PlaySound("bike_land")
	onGround = true
	if(groundSound == -1)then
		groundSound = SFX.PlaySound("dullahan_bike_engine_lp",true)
	end
	Log("HitGround")
end

function ChristmasSantaHog.Mount()
	SFX.PlaySound("bike_start")
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	wheelie = true
end

function ChristmasSantaHog.TouchUp()

	inputUp = true
end

function ChristmasSantaHog.TouchDown()
	Log("TouchDown")

end

function ChristmasSantaHog.OnJump()
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	jumpCounter = 0.45
	jumpMove = 0.0
	randomJump = math.random(3)
	if(randomJump == 1)then
		SFX.PlaySound("bike_jump")
	elseif(randomJump == 2)then
		SFX.PlaySound("bike_jump")
	elseif(randomJump == 3)then
		SFX.PlaySound("bike_jump")
	end
	onGround = false
	shootGun = false
	inputUp = false
end

function ChristmasSantaHog.Explode()
	Log("Explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	SFX.PlaySound("mech_explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
end

function ChristmasSantaHog:OnDestroy(didQuit)
	SFX.StopSound(groundSound)
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("ChristmasSantaHog", "Hog", ChristmasSantaHog);