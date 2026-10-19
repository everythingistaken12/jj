Log("HoverHog Lua script started")

local HoverHog = {}
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


local headPos

function HoverHog.GetTextureList()
	return "textures/Characters/Vehicles/Hog/HoverHog/jumpDust.tex|textures/Characters/Vehicles/Hog/HoverHog/landDust.tex|textures/Characters/Vehicles/Hog/HoverHog/effect_bikeplasmagun.tex|textures/Characters/Vehicles/Hog/HoverHog/effect_skidsmoke.tex"
end

function HoverHog.GetConstructionRenderFlags(phase)
	return -1
end

function HoverHog:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function HoverHog.ComponentComplete()

end

function HoverHog:ConstructionComplete()
	Log("Construction!")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end


function HoverHog:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	onGround = false
	groundSound = -1
	SetHogEffects(false)
	gunBlast = LoadTexture("textures/Characters/Vehicles/Hog/HoverHog/effect_bikeplasmagun.xml", 10)
	wheelieDust = LoadTexture("textures/Characters/Vehicles/Hog/HoverHog/effect_skidsmoke.xml", 10)
	jumpDust = LoadTexture("textures/Characters/Vehicles/Hog/HoverHog/jumpDust.xml", 10)
	landDust = LoadTexture("textures/Characters/Vehicles/Hog/HoverHog/landDust.xml", 10)
	Log("Init Particles!")
end

function HoverHog.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function HoverHog:Ready(skipPickupSeq)
	Log("Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
end

function HoverHog:OnUpdate(dt)
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
			groundSound = SFX.PlaySound("hover_engine_lp",true)
		end
		wheelie = false
	elseif(shootGun == true and frame == 5)then
		SFX.PlaySound("hover_gun_spin")
		shootGun = false
	end
end

function HoverHog:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
	if(jumpCounter > 0.0)then
		DrawTexture(jumpDust, headPos[1] + 35 - jumpMove, -80 )
	end
	if(landCounter > 0.0)then
		DrawTexture(landDust, headPos[1] + 15 - landMove, -135 )
	end
	if(gunBlastCounter > 0.0)then
		DrawTexture(gunBlast, headPos[1] + 80, headPos[2]  + 15)
	end
	if(wheelieDustCounter > 0.0)then
		DrawTexture(wheelieDust, headPos[1] - 55, headPos[2]  + 10)
	end
end


function HoverHog.ShootGun()
	Log("Shoot Gun")
	SFX.PlaySound("hover_gun_fire")
	PlayAnimation(gunBlast, "fire")
	gunBlastCounter = 0.3
	shootGun = true
end

function HoverHog.HitGround()
	landCounter = 0.4
	landMove = 0.0
	PlayAnimation(landDust, "land")
	SFX.PlaySound("hover_land")
	onGround = true
	if(groundSound == -1)then
		groundSound = SFX.PlaySound("hover_engine_lp",true)
	end
	Log("HitGround")
end

function HoverHog.Mount()
	SFX.PlaySound("hover_start")
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	wheelie = true
end

function HoverHog.TouchUp()

	inputUp = true
end

function HoverHog.TouchDown()
	Log("TouchDown")

end

function HoverHog.OnJump()
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	jumpCounter = 0.45
	jumpMove = 0.0
	PlayAnimation(jumpDust, "jump")
	randomJump = math.random(3)
	if(randomJump == 1)then
		SFX.PlaySound("hover_jump_1")
	elseif(randomJump == 2)then
		SFX.PlaySound("hover_jump_2")
	elseif(randomJump == 3)then
		SFX.PlaySound("hover_jump_3")
	end
	onGround = false
	shootGun = false
	inputUp = false
end

function HoverHog.Explode()
	Log("Explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	SFX.PlaySound("hover_explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
end

function HoverHog:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("HoverHog", "Hog", HoverHog);