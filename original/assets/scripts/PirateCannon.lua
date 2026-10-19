Log("PirateCannon Lua script started")

local PirateCannon = {}
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
local fuseParticle
local blastParticle

local headPos

function PirateCannon.GetTextureList()
	return "textures/Characters/Vehicles/Hog/PirateCannon/jumpDust.tex|textures/Characters/Vehicles/Hog/PirateCannon/landDust.tex|textures/Characters/Vehicles/Hog/PirateCannon/effect_cannonBlast.tex|textures/Characters/Vehicles/Hog/PirateCannon/effect_skidsmoke.tex"
end

function PirateCannon.GetConstructionRenderFlags(phase)
	-- 1 for jetpack
	-- 2 for head
	-- 4 for body
	return 6
end

function PirateCannon:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function PirateCannon.ComponentComplete()

end

function PirateCannon:ConstructionComplete()
	SFX.PlaySound("cannon_form_complete")
	Log("Construction!")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end


function PirateCannon:OnInit(info)
	self.Base.OnInit(self, info)
	
	OverloadVehicleSounds()
	onGround = false
	groundSound = -1
	SetHogEffects(false)
	SetDrawBody(true)	
	gunBlast = LoadTexture("textures/Characters/Vehicles/Hog/PirateCannon/effect_cannonBlast.xml", 10)
	wheelieDust = LoadTexture("textures/Characters/Vehicles/Hog/PirateCannon/effect_skidsmoke.xml", 10)
	jumpDust = LoadTexture("textures/Characters/Vehicles/Hog/PirateCannon/jumpDust.xml", 10)
	landDust = LoadTexture("textures/Characters/Vehicles/Hog/PirateCannon/landDust.xml", 10)

	fuseParticle = CreateParticle("PirateCannonFuse")
	blastParticle = CreateParticle("PirateCannonBlast")
	SetParticleEnabled(fuseParticle, false)
	SetParticleEnabled(blastParticle, false)
end

function PirateCannon.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function PirateCannon:Ready(skipPickupSeq)
	Log("Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
	SetParticleEnabled(fuseParticle, true)
end

function PirateCannon:OnUpdate(dt)
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
			groundSound = SFX.PlaySound("cannon_move_lp",true)
		end
		wheelie = false
	elseif(shootGun == true and frame == 5)then
		shootGun = false
		SetParticleEnabled(blastParticle, false)
	end
end

function PirateCannon:OnDraw()
	self.Base.OnDraw(self)
	
	headPos = Vector.New(GetPlayerPosition())
	worldPos = Vector.New(Level.GetOffset())

	fuseParticlePos = headPos + Vector.New(5.0, -4.0)
	fuseParticlePosOffset = fuseParticlePos - worldPos
	blastParticlePosOffset = fuseParticlePos - worldPos

	if(jumpCounter > 0.0)then
		DrawTexture(jumpDust, headPos[1] + 35 - jumpMove, -80 )
	end
	if(landCounter > 0.0)then
		DrawTexture(landDust, headPos[1] + 15 - landMove, -135 )
	end
	if(gunBlastCounter > 0.0)then
		DrawTexture(gunBlast, headPos[1] + 95, headPos[2])
	end
	if(wheelieDustCounter > 0.0)then
		DrawTexture(wheelieDust, headPos[1] - 55, headPos[2]  + 10)
	end
	SetParticlePosition(fuseParticle, fuseParticlePosOffset[1] - 27, fuseParticlePosOffset[2] + 13)
	SetParticlePosition(blastParticle, blastParticlePosOffset[1] + 45, blastParticlePosOffset[2] + 10)
end

function PirateCannon.ShootGun()
	Log("Shoot Gun")
	SFX.PlaySound("cannon_attack")
	PlayAnimation(gunBlast, "fire")
	gunBlastCounter = 0.3
	shootGun = true
	SetParticleEnabled(blastParticle, true)
end

function PirateCannon.HitGround()
	landCounter = 0.4
	landMove = 0.0
	PlayAnimation(landDust, "land")
	SFX.PlaySound("cannon_land")
	onGround = true
	if(groundSound == -1)then
		groundSound = SFX.PlaySound("cannon_move_lp",true)
	end
	Log("HitGround")
end

function PirateCannon.Mount()
	SFX.PlaySound("cannon_land")
	wheelieDustCounter = 0.6
	PlayAnimation(wheelieDust, "mount")
	gunBlastCounter = 0.3
	PlayAnimation(gunBlast, "fire")
	SetParticleEnabled(blastParticle, true)
	wheelie = true
end

function PirateCannon.TouchUp()

	inputUp = true
end

function PirateCannon.TouchDown()
	Log("TouchDown")

end

function PirateCannon.OnJump()
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	jumpCounter = 0.45
	jumpMove = 0.0
	PlayAnimation(jumpDust, "jump")
	randomJump = math.random(3)
	if(randomJump == 1)then
		SFX.PlaySound("cannon_jump")
	elseif(randomJump == 2)then
		SFX.PlaySound("cannon_jump")
	elseif(randomJump == 3)then
		SFX.PlaySound("cannon_jump")
	end
	onGround = false
	shootGun = false
	inputUp = false
end

function PirateCannon.Explode()
	Log("Explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
	SFX.PlaySound("cannon_explode")
	
	SFX.StopSound(groundSound or -1,0.1)
	groundSound = -1
end

function PirateCannon:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("PirateCannon", "Hog", PirateCannon);