Log("Dullahan Lua script started")

local Dullahan = {}
local jumpDust
local landDust
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
local fireTrail
local headTrail


local headPos

function Dullahan.GetTextureList()
	return "textures/Characters/Vehicles/Hog/Dullahan/jumpDust.tex|textures/Characters/Vehicles/Hog/Dullahan/landDust.tex|textures/Characters/Vehicles/Hog/Dullahan/effect_dullahanWhip.tex|textures/Characters/Vehicles/Hog/Dullahan/effect_skidsmoke.tex"
end

function Dullahan.GetConstructionRenderFlags(phase)
	return -1
end

function Dullahan.ComponentComplete()

end

function Dullahan:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Dullahan:ConstructionComplete()
	VehicleUtils.PlaySong(self, "music", "construction_complete")
	SFX.PlaySound("dullahan_form_complete")
	Log("Construction!")
end


function Dullahan:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	onGround = false
	groundSound = -1
	SetHogEffects(false)
	gunBlast = LoadTexture("textures/Characters/Vehicles/Hog/Dullahan/effect_dullahanWhip.xml", 10)
	wheelieDust = LoadTexture("textures/Characters/Vehicles/Hog/Dullahan/effect_skidsmoke.xml", 10)
	jumpDust = LoadTexture("textures/Characters/Vehicles/Hog/Dullahan/jumpDust.xml", 10)
	landDust = LoadTexture("textures/Characters/Vehicles/Hog/Dullahan/landDust.xml", 10)
	Log("Init Particles!")
	fireTrail = CreateParticle("DullahanTrail")
	headTrail = CreateParticle("DullahanHeadTrail")	
	SetParticleEnabled(fireTrail, false)
	SetParticleEnabled(headTrail, false)
	self:SetDrawHead(false)
end

function Dullahan:PickupSequenceUpdate(dt)
	VehicleUtils.PlaySong(self, "music", "pickup_sequence")
	Log("PickupSequenceUpdate")
end

function Dullahan:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
	Log("Ready")
	SetParticleEnabled(fireTrail, true)
	SetParticleEnabled(headTrail, true)		
end

function Dullahan:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
	if(jumpCounter > 0.0)then
		jumpCounter = jumpCounter - dt
		jumpMove = jumpMove + 3
	SetParticleEnabled(fireTrail, false)
	SetParticleEnabled(headTrail, false)			
	end	
	if(landCounter > 0.0)then
		landCounter = landCounter - dt
		landMove = landMove + 3
	SetParticleEnabled(fireTrail, true)	
	SetParticleEnabled(headTrail, true)		
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

function Dullahan:OnDraw()
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
		DrawTexture(gunBlast, headPos[1] + 35, headPos[2]  + 15)
	end
	if(wheelieDustCounter > 0.0)then
		DrawTexture(wheelieDust, headPos[1] - 55, headPos[2]  + 10)
	end
	SetParticlePosition(fireTrail, finalFirePos[1], finalFirePos[2])
	SetParticlePosition(headTrail, headFirePos[1] - 7, headFirePos[2] + 20)	
end


function Dullahan.ShootGun()
	Log("Shoot Gun")
	SFX.PlaySound("dullahan_whip_attack")
	PlayAnimation(gunBlast, "fire")
	gunBlastCounter = 0.3
	shootGun = true
end

function Dullahan.HitGround()
	landCounter = 0.4
	landMove = 0.0
	PlayAnimation(landDust, "land")
	SFX.PlaySound("bike_land")
	onGround = true
	if(groundSound == -1)then
		groundSound = SFX.PlaySound("dullahan_bike_engine_lp",true)
	end
	Log("HitGround")
end

function Dullahan.Mount()
	SFX.PlaySound("dullahan_bike_start")
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	wheelie = true
end

function Dullahan.TouchUp()

	inputUp = true
end

function Dullahan.TouchDown()
	Log("TouchDown")

end

function Dullahan.OnJump()
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	jumpCounter = 0.45
	jumpMove = 0.0
	PlayAnimation(jumpDust, "jump")
	randomJump = math.random(3)
	if(randomJump == 1)then
		SFX.PlaySound("dullahan_bike_jump")
	elseif(randomJump == 2)then
		SFX.PlaySound("dullahan_bike_jump")
	elseif(randomJump == 3)then
		SFX.PlaySound("dullahan_bike_jump")
	end
	onGround = false
	shootGun = false
	inputUp = false
end

function Dullahan.Explode()
	Log("Explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	SFX.PlaySound("mech_explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
end

function Dullahan:OnDestroy(didQuit)
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("Dullahan", "Hog", Dullahan);