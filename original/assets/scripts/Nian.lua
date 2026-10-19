Log("Nian Lua script started")

local Nian = {}
local jumpDust
local landDust
local gunBlast
local fireworks
local wheelieDust
local jumpCounter = 0.0
local jumpMove = 0.0
local landMove = 0.0
local landCounter = 0.0
local gunBlastCounter = 0.0
local wheelieDustCounter = 0.0
local wheelie = false
local shootGun = false

local headPos

function Nian.GetTextureList()
	return "textures/Characters/Vehicles/Hog/Nian/jumpDust.tex|textures/Characters/Vehicles/Hog/Nian/landDust.tex|textures/Characters/Vehicles/Hog/Nian/effect_fireworkGun.tex"
end

function Nian.GetConstructionRenderFlags(phase)
	return -1
end

function Nian.ComponentComplete()

end

function Nian:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Nian:ConstructionComplete()
	VehicleUtils.PlaySong(self, "music", "construction_complete")
	SFX.PlaySound("nian_form_complete")
	Log("Construction!")
end


function Nian:OnInit(info)
	self.Base.OnInit(self, info)
	SetHogEffects(false)
	gunBlast = LoadTexture("textures/Characters/Vehicles/Hog/Nian/effect_fireworkGun.xml", 10)
	wheelieDust = LoadTexture("textures/Characters/Vehicles/Hog/Nian/effect_skidsmoke.xml", 10)
	jumpDust = LoadTexture("textures/Characters/Vehicles/Hog/Nian/jumpDust.xml", 10)
	landDust = LoadTexture("textures/Characters/Vehicles/Hog/Nian/landDust.xml", 10)

	fireworks = LoadTexture("textures/Effects/effect_fireworks.xml", 20)
end

function Nian.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function Nian:Ready(skipPickupSeq)
	Log("Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
end

function Nian:OnUpdate(dt)
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

end

function Nian:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())

	firePos = headPos + Vector.New(5.0, -4.0)
	worldPos = Vector.New(Level.GetOffset())
	finalFirePos = firePos - worldPos
	headFirePos = firePos - worldPos

	if(jumpCounter > 0.0)then
		DrawTexture(jumpDust, headPos[1] + 35 - jumpMove, -80 )
	end
	if(landCounter > 0.0)then
		DrawTexture(landDust, headPos[1] + 15 - landMove, -135 )

	end
	if(gunBlastCounter > 0.0)then
		DrawTexture(gunBlast, headPos[1] + 80, headPos[2]  + 15)	
		DrawTexture(fireworks, headPos[1] + 150, headPos[2]  + 15)		
	end
	if(wheelieDustCounter > 0.0)then
		DrawTexture(wheelieDust, headPos[1] - 55, headPos[2]  + 10)
	end
end


function Nian.ShootGun()
	Log("Shoot Gun")
	PlayAnimation(gunBlast, "fire")	
	PlayAnimation(fireworks, "fire")
		shootSound = math.random(3)
	if(shootSound == 1)then
		SFX.PlaySound("nian_bike_gun_fire_01")
	elseif(shootSound == 2)then
		SFX.PlaySound("nian_bike_gun_fire_02")
	elseif(shootSound == 3)then
		SFX.PlaySound("nian_bike_gun_fire_03")
	end
	gunBlastCounter = 0.3
	shootGun = true
end

function Nian.HitGround()
	landCounter = 0.4
	landMove = 0.0
	PlayAnimation(landDust, "land")
end

function Nian.Mount()
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	wheelie = true
end

function Nian.TouchUp()

	inputUp = true
end

function Nian.TouchDown()
	Log("TouchDown")

end

function Nian.OnJump()
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	jumpCounter = 0.45
	jumpMove = 0.0
	PlayAnimation(jumpDust, "jump")

	shootGun = false
	inputUp = false
end

function Nian.Explode()
	Log("Explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
end

function Nian:OnDestroy(didQuit)
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("Nian", "Hog", Nian);