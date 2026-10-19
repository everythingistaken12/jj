Log("TMNTHog Lua script started")

local TMNTHog = {}
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


local headPos

function TMNTHog.ComponentComplete()

end

function TMNTHog:ConstructionComplete()
	VehicleUtils.PlaySong(self, "music", "construction_complete")
	SFX.PlaySound("ms_vehicle_form_complete")
	Log("Construction!")
end

function TMNTHog:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function TMNTHog:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	onGround = false
	groundSound = -1
	SetHogEffects(false)
	gunBlast = LoadTexture("textures/Effects/effect_bikeshotgun.xml", 10)
	Log("Init Particles!")
end

function TMNTHog:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
	Log("Ready")
end

function TMNTHog:OnUpdate(dt)
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
			groundSound = SFX.PlaySound("ms_hog_engine_lp",true)
		end
		wheelie = false
	end
end

function TMNTHog:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())

	worldPos = Vector.New(Level.GetOffset())

	if(gunBlastCounter > 0.0)then
		DrawTexture(gunBlast, headPos[1] + 35, headPos[2]  + 15)
	end
	if(wheelieDustCounter > 0.0)then
		DrawTexture(wheelieDust, headPos[1] - 55, headPos[2]  + 10)
	end
end


function TMNTHog.ShootGun()
	Log("Shoot Gun")
	SFX.PlaySound("Bike_gun_2")
	PlayAnimation(gunBlast, "fire")
	gunBlastCounter = 0.3
	shootGun = true
end

function TMNTHog.HitGround()
	landCounter = 0.4
	landMove = 0.0
	SFX.PlaySound("bike_land")
	onGround = true
	if(groundSound == -1)then
		groundSound = SFX.PlaySound("ms_hog_engine_lp",true)
	end
	Log("HitGround")
end

function TMNTHog.Mount()
	SFX.PlaySound("ms_hog_start")
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	wheelie = true
end

function TMNTHog.TouchUp()

	inputUp = true
end

function TMNTHog.TouchDown()
	Log("TouchDown")

end

function TMNTHog.OnJump()
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	jumpCounter = 0.45
	jumpMove = 0.0
	randomJump = math.random(3)
	if(randomJump == 1)then
		SFX.PlaySound("ms_hog_jump")
	elseif(randomJump == 2)then
		SFX.PlaySound("ms_hog_jump")
	elseif(randomJump == 3)then
		SFX.PlaySound("ms_hog_jump")
	end
	onGround = false
	shootGun = false
	inputUp = false
end

function TMNTHog.Explode()
	Log("Explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	SFX.PlaySound("ms_vehicle_explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
end

function TMNTHog:OnDestroy(didQuit)
	SFX.StopSound(groundSound)
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("TMNTHog", "Hog", TMNTHog);