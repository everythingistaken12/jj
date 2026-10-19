Log("BoneDragon Lua script started")

BoneDragon = {}

local red
local blue
local purple
local orange
local yellow
local green
local head
local jaw
local jawRot
local jawOffset
local headOffset
local hornOffset
local fireBreathPos
local maxJawRot
local tailPos
local renderPos
local renderAngle
local sinSpeed
local amp
local currentY
local angle
local pieceCount
local renderCount
local renderIdx
local colDist
local colScale
local inputUp
local dirty
local inputVel
local velocity
local playerOffset
local pullUpAdditive
local roofHeight
local easeInDist
local returnRoofVel
local returnRoofAdditive
local maxXPos
local xEaseInDist
local minRestPos
local leftRestPos
local xReturnSpeed
local xReturnVel
local xVel
local diveAdditive
local maxYVel
local smashGround
local diveEffect
local colossatronFire
local colossatronDust
local boneDragonSpeed
local boneDragonGold
local headRot
local explosions
local exploded
local explosionDelay
local explosionTimer

local primaryTex
local topsideTex
local bottomSideTex
local backHornTex
local glowingEyeTex

local randComponents
local component

local isReady
local groundSound
local playGroundSound
local impactThreshold
local playFireSound

local flySound = -1
local playingflySound = false

local divingSound = -1
local playingDivingSound = false

local noseFlame

local fireTimer
local rateOfFire
local randFireAngle
local minFireVel
local maxFireVel
local fireLifeTime
local smokeLifeTime
local friction
local fricDelay

local flashOffset

local shadowTex

-- Function forward declares
local InitVars
local Wrap
local RenderPosition
local RotateVector
local RotateOffset
local UpdateFinalPosition
local OffsetEverything
local PrintRenderPositions
local Sign
local Clamp
local LogVec

function BoneDragon.GetTextureList()
	return
		"textures/Characters/Vehicles/dragon/BoneDragon/dragonBody1.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/dragonBody2.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/dragonBody1_cracked.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/dragonBody2_cracked.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/dragonBodySattle.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/DragonHead.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/DragonJaw.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/backHorn.tex"..
		"|textures/Characters/Vehicles/dragon/BoneDragon/glowingEye.tex"
end

function BoneDragon:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function BoneDragon:ComponentComplete()
	local componentSound = math.random(#self.componentCompleteSfx)
	SFX.PlaySound(self.componentCompleteSfx[componentSound])
end

function BoneDragon:ConstructionComplete()
	SFX.PlaySound(self.constructionCompleteSfx)
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function InitVars()

	OverloadPickupSounds()
	OverloadVehicleSounds()

	jawRot = 0.0
	jawOffset = Vector.New(-5.0, -4.0)
	headOffset = Vector.New(-20.0, 0.0)
	hornOffset = Vector.New(0,0)
	maxJawRot = 1.0
	tailPos = {}
	renderPos = {}
	renderAngle = {}
	sinSpeed = 5.2
	amp = 6.0
	angle = 0.0
	pieceCount = 256
	renderCount = 35
	renderIdx = 0
	colDist = 135.0
	inputUp = true
	dirty = false
	inputVel = Vector.New(1.0, 0.0)
	velocity = Vector.New(0.0, 0.0)
	pullUpAdditive = 0.2
	roofHeight = 120.0
	easeInDist = 8.0
	returnRoofVel = 2.3
	returnRoofAdditive = 0.14
	maxXPos = GetVehicleRestPosition()
	xEaseInDist = 64.0
	leftRestPos = 397.0
	xReturnSpeed = 1.0
	xReturnVel = 0.0
	xVel = 0.7
	diveAdditive = 0.2
	maxYVel = 5.5
	headRot = 0.0
	explosions = {}
	exploded = 0
	explosionDelay = 0.10
	explosionTimer = 0.0


	primaryTex = {}
	topSideTex = {}
	bottomSideTex = {}

	randComponents = false
	component = {}

	isReady = true
	playGroundSound = 0
	impactThreshold = -1.0
	playFireSound = 0

	fireTimer = 0.0
	rateOfFire = 0.0
	randFireAngle = 8.0
	minFireVel = 8.0
	maxFireVel = 10.0
	fireLifeTime = 0.15
	smokeLifeTime = 0.25
	friction = 0.95
	fricDelay = 0.0
end

function BoneDragon:GetSkinVectorAttributeOrDefault(name, x, y)
	local tx, ty = self:GetSkinVectorAttribute(name)
	return Vector.New(tx or x, ty or y)
end

function BoneDragon:InitSkin()
	self.primary = self:GetSkinArrayAttribute("primary") or { "dragonBodySaddle" }

	self.skinName = self:GetSkinAttribute("skinName") or "BoneDragon"
	self.secondary = self:GetSkinArrayAttribute("secondary") or { "dragonBody2", "dragonBody2_cracked" }
	self.secondaryLayer = self:GetSkinAttribute("secondaryLayer") or 9
	self.renderPosOverlap = self:GetSkinNumberAttribute("renderPosOverlap") or 13.5;
	self.numConstructionComponents = self:GetSkinNumberAttribute("numConstructionComponents") or 1;
	self.maxComponents = self:GetSkinNumberAttribute("maxComponents") or 35;
	self.maxExplosions = self:GetSkinNumberAttribute("maxExplosions") or 4;	

	self.componentCompleteSfx = self:GetSkinArrayAttribute("componentCompleteSfx") 
		or { "bone_dragon_form_1", "bone_dragon_form_2", "bone_dragon_form_3", "bone_dragon_form_4" }

	self.constructionCompleteSfx = self:GetSkinAttribute("constructionCompleteSfx") or "bone_dragon_form_complete"
	self.dragonLandHardSfx = self:GetSkinAttribute("dragonLandHardSfx") or "bone_dragon_land_hard"
	self.dragonExplodeDebrisSfx = self:GetSkinAttribute("dragonExplodeDebrisSfx") or "bone_dragon_explode_debris"
	self.grindLpSfx = self:GetSkinAttribute("dragonGrindLp") or "colossatron_grind_lp"
	self.grindStopSfx = self:GetSkinAttribute("dragonGrindStop") or "colossatron_grind_stop"
	self.fireStopSfx = self:GetSkinAttribute("dragonFireStopSfx") or "colossatron_fire_stop"

	self.flyLpSfx = self:GetSkinAttribute("dragonFlyLp") or "cuddles_fly_lp";
	self.flyLpFadeOut = self:GetSkinNumberAttribute("dragonFlyLpFadeOut") or 0.4;

	self.dragonDiveSfx = self:GetSkinArrayAttribute("dragonDiveSfx") or nil;
	self.dragonDiveSfxFadeOut = self:GetSkinNumberAttribute("dragonDiveSfxFadeOut") or 3.0;

	self.dragonCrashParticles = self:GetSkinAttribute("dragonCrashParticles") or "Colossatron_crash"
	self.dragonDiveEffectParticles = self:GetSkinAttribute("dragonDiveEffectParticles") or nil;
	self.dragonSpeedParticles = self:GetSkinAttribute("dragonSpeedParticles") or "BoneDragon_speed"
	self.dragonDustParticles = self:GetSkinAttribute("dragonDustParticles") or "colossatron_dust_cloud"
	self.dragonGoldParticles = self:GetSkinAttribute("dragonGoldParticles") or "GoldSparkle_DragonHead"

	playerOffset = self:GetSkinVectorAttributeOrDefault("drawingOffsets_playerOffset", 0.0, -12.0)
	self.collisionOffset = self:GetSkinVectorAttributeOrDefault("collisionOffset", -30.0, 3.0)

	fireBreathPos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_fireBreathPos", -18.0, 0.0)

	self.hasJaw = self:GetSkinBoolAttributeOrDefault("hasJaw", true)
	self.hasHeadAnim = self:GetSkinBoolAttributeOrDefault("hasHeadAnim", false)
	self.jawSpeed = self:GetSkinNumberAttribute("jawSpeed") or 3.5;

	self.drawingOffsets = {
		flashOffset = self:GetSkinVectorAttributeOrDefault("drawingOffsets_flashOffset", 0.0, 12.0),
		headPos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_headPos", 20.0, 5.0),
		eyePos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_eyePos", 23.0, 2.0),
		hornPos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_hornPos", -10,15),
		jawPos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_jawPos", -3.0, -16.0),
		rubblePos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_rubblePos", 20.0, -30.0),
		dustPos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_dustPos", 0.0, -20.0),
		speedPos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_speedPos", 5.0, -4.0),
		nosePos = self:GetSkinVectorAttributeOrDefault("drawingOffsets_nosePos", 30.0, -5.0)
	}

	self.enableNoseFlame = self:GetSkinBoolAttributeOrDefault("enableNoseFlame", true)

	self.enableGoldParticles = self:GetSkinBoolAttributeOrDefault("enableGoldParticles", false)

	self.breatheFire = self:GetSkinBoolAttributeOrDefault("breatheFire", true)

	self.overloadShadow = self:GetSkinBoolAttributeOrDefault("overloadShadow", false)
	self.shadowSize = self:GetSkinVectorAttributeOrDefault("shadowSize", 2.0, 1.0)
end

function BoneDragon:OnInit(info)
	self.Base.OnInit(self, info)

	self:InitSkin()
	InitVars()
	
	if self.overloadShadow then	
		OverloadVehicleShadow()
	end

	local filePath = "textures/Characters/Vehicles/dragon/"..self.skinName.."/"
	local pickupPath = "textures/Characters/Vehicles/Components/Dragon/"..self.skinName.."/Component"

	if self.overloadShadow then
		shadowTex = LoadTexture("textures/Effects/effect_shadow.xml",9)
	end

	primaryTex[1] = LoadTexture(filePath..self.primary[1]..".xml", self.secondaryLayer)

	for i = 1, self.maxComponents, 1 do
		local cracked = math.random(#self.secondary)
		topSideTex[i] = LoadTexture(filePath..self.secondary[cracked]..".xml", 9)
		component[i] = cracked
	end

	head = LoadTexture(filePath.."DragonHead.xml", 12)

	if self.hasJaw then
		jaw = LoadTexture(filePath.."DragonJaw.xml", 12)
	end

	backHornTex = LoadTexture(filePath.."backHorn.xml", 7)
	glowingEyeTex = LoadTexture(filePath.."glowingEye.xml", 12)
	for i = 1, self.maxExplosions, 1 do
		explosions[i] = LoadTexture("textures/Entities/missileExplosion.xml", 12)
	end

	smashGround = CreateParticle(self.dragonCrashParticles)
	if self.dragonDiveEffectParticles ~= nil then
		diveEffect = CreateParticle(self.dragonDiveEffectParticles)
	end
	colossatronDust = CreateParticle("colossatron_dust_cloud")
	boneDragonSpeed = CreateParticle(self.dragonSpeedParticles)

	SetParticleEnabled(smashGround, false)
	if diveEffect ~= nil then
		SetParticleEnabled(diveEffect, false)
	end
	SetParticleEnabled(colossatronDust, false)
	SetParticleEnabled(boneDragonSpeed, true)

	if self.enableNoseFlame then
		noseFlame = CreateParticle("Bone_Dragon_Nose")
		SetParticleEnabled(noseFlame, false)
	end

	if self.enableGoldParticles then
		boneDragonGold = CreateParticle(self.dragonGoldParticles)
		SetParticleEnabled(boneDragonGold, true)
	end

	pos = Vector.New(GetPlayerPosition())
	colScale = Vector.New(18.0, 20.0)

	local screenSize = Vector.New(GetScreenSize())
	minRestPos = (screenSize[1]/2) - leftRestPos
	currentY = pos[2]
	a = angle

	for i = 1, pieceCount, 1 do
		a = Wrap(a - sinSpeed, 0.0, 359.0)
		tailPos[i] = Vector.New(pos[2] - 4.0, currentY + (math.sin(math.rad(a)) * amp))
	end

	self:CalculateRenderPositions()
	ClearPickupComponents()

	for j = 1, self.numConstructionComponents, 1 do
		AddPickupComponent(pickupPath..j..".tex", 16)
	end

	if (self.numConstructionComponents < 2) then
		AddPickupComponent(filePath..self.primary[1]..".tex", 9)
	end

	i = 2
	while renderPos[i] and self.numConstructionComponents < 2 do
		AddPickupComponent(filePath..self.secondary[component[i]]..".tex", 9)
		i = i + 1
	end

	SetCollisionOffset(self.collisionOffset[1],self.collisionOffset[2])
	
	flashOffset = self.drawingOffsets.flashOffset
end

function BoneDragon.PickupSequenceUpdate(dt)
end

function BoneDragon:Ready(skipPickupSeq)
	isReady = true
	VehicleUtils.PlaySong(self, "music", "ready")

	if (string.len(self.flyLpSfx) > 0) then
		flySound = SFX.PlaySound(self.flyLpSfx, true)
		playingflySound = true
	end
end

local function UpdateBreatheFire(dt)

	fireTimer = fireTimer - dt
	playerPos = Vector.New(GetPlayerPosition())

	if(fireTimer < 0.0 and inputUp ~= true and jawRot <= (-maxJawRot + 0.4))then

		if(playFireSound == 0)then
			colossatronFire = SFX.PlaySound("colossatron_fire_lp", true)
			playFireSound = 1
		end

		fireAngle = headRot + 90.0
		fireAngle = fireAngle + (math.random(randFireAngle*2)-randFireAngle)
		vel = minFireVel + ((math.random(100)/100) * (maxFireVel-minFireVel))
		velocity = Vector.New(math.sin(math.rad(fireAngle)) * vel, -math.cos(math.rad(fireAngle)) * vel)
		spawnPos = RenderPosition(playerPos, fireBreathPos, math.rad(headRot))

		BreathFire(spawnPos[1], spawnPos[2], velocity[1], velocity[2], fireLifeTime, friction, fricDelay, true)
		BreathFire(spawnPos[1], spawnPos[2], velocity[1], velocity[2], smokeLifeTime, friction, fricDelay, false)

		fireTimer = rateOfFire
	end
end

function BoneDragon:OnUpdate(dt)
	playerPos = Vector.New(GetPlayerPosition())
	if(exploded > 0)then
		dt = 0.01666 -- we've frozen the game at this point, so dt is coming through as 0
		explosionTimer = explosionTimer - dt
		if(explosionTimer <= 0.0)then
			if(exploded <= self.maxExplosions)then
				explosionTimer = explosionDelay
				PlayAnimation(explosions[exploded], "expl")
				exploded = exploded + 1
				SFX.PlaySound("cuddles_explode")
				SFX.PlaySound(self.dragonExplodeDebrisSfx)
			else
				self:SetupFrags()
				Level.DisableVehicles()
				CreateEmp(playerPos[1], playerPos[2])
				Level.ForceCoins(1)
				SelfDestruct()
			end
		end

		return
	end

	if self.enableNoseFlame then
		if inputUp then
			noseFireEnabled = math.random(300)
			if(noseFireEnabled > 295)then
				SetParticleEnabled(noseFlame, true)
			else
				SetParticleEnabled(noseFlame, false)
			end
		else
			SetParticleEnabled(noseFlame, false)
		end
	end

	velocity = Vector.New(VehicleUpdateSpeed(dt))

	for i = pieceCount - 1, 1, -1 do
		tailPos[i+1] = tailPos[i]
	end
	tailPos[1] = Vector.Clone(playerPos)

	if(inputUp == true)then
		playerPos = self:UpdateInputUp(playerPos, dt)
		jawRot = math.min(jawRot + (self.jawSpeed * dt), 0.0)
	else
		playerPos = self:UpdateInputDown(playerPos, dt)
		jawRot = math.max(jawRot - (self.jawSpeed * dt), -maxJawRot)
	end

	playerPos = UpdateFinalPosition(playerPos, dt)

	SetPlayerPosition(playerPos[1], playerPos[2])
	self:CalculateRenderPositions()

	if (self.breatheFire == true) then
		UpdateBreatheFire(dt)
	else
		return
	end

	UpdatePlayerAnim()
	UpdateVehicleParticles()
end

function BoneDragon:OnDraw()
	playerPos = Vector.New(GetPlayerPosition())
	worldPos = Vector.New(Level.GetOffset())
	headPos = playerPos + RotateVector(self.drawingOffsets.headPos, math.rad(headRot))

	eyePos = playerPos + RotateVector(self.drawingOffsets.eyePos, math.rad(headRot))
	headPos = RotateOffset(headPos + headOffset, headPos, (-jawRot / 2))
	hornPos = headPos + self.drawingOffsets.hornPos
	eyePos = RotateOffset(eyePos + headOffset, eyePos, (-jawRot / 2))

	jawPos = headPos + RotateVector(self.drawingOffsets.jawPos, math.rad(headRot))
	jawPos = RotateOffset(jawPos + jawOffset, jawPos, (jawRot / 2))
	rubblePos = headPos + self.drawingOffsets.rubblePos
	dustPos = headPos + self.drawingOffsets.dustPos
	speedPos = headPos + self.drawingOffsets.speedPos
	nosePos = headPos + self.drawingOffsets.nosePos

	
	DrawTexture(head, headPos[1], headPos[2], headRot - math.deg(jawRot / 2))
	DrawTexture(backHornTex, hornPos[1], hornPos[2], headRot - math.deg(jawRot / 2) )
	if self.hasJaw then
		DrawTexture(jaw, jawPos[1], jawPos[2], headRot + math.deg(jawRot / 2) )
	end
	DrawTexture(glowingEyeTex, eyePos[1], eyePos[2], headRot + math.deg(jawRot / 2) )

	for i = self.maxComponents, 1, -1 do
		if (renderPos[i] ~= nil) then
			if (i == 1) then
				DrawTexture(primaryTex[1], renderPos[i][1], renderPos[i][2], renderAngle[i])
			else
				DrawTexture(topSideTex[i], renderPos[i][1], renderPos[i][2], renderAngle[i])
			end

			if (i <= exploded) then
				DrawTexture(explosions[i], renderPos[i][1], renderPos[i][2], renderAngle[i])
			end
		end
	end

	finalRubblePos = rubblePos - worldPos
	finalSpeedPos = speedPos - worldPos

	SetParticlePosition(smashGround, finalRubblePos[1], finalRubblePos[2])
	if diveEffect ~= nil then
		SetParticlePosition(diveEffect, finalSpeedPos[1], finalSpeedPos[2])
	end		
	SetParticlePosition(colossatronDust, dustPos[1], dustPos[2])
	if self.enableNoseFlame then
		finalNosePos = nosePos - worldPos
		SetParticlePosition(noseFlame, finalNosePos[1], finalNosePos[2])
	end
	SetParticlePosition(boneDragonSpeed, finalSpeedPos[1], finalSpeedPos[2])
	SetParticlePosition(boneDragonGold, finalSpeedPos[1], finalSpeedPos[2])

	if(renderAngle[1] ~= nil)then
		playerAngle = Wrap(renderAngle[1], -180.0, 180.0)
		final = RenderPosition(renderPos[1], playerOffset, math.rad(-playerAngle))
		DrawPlayer(final[1], final[2], playerAngle/2, playerAngle/2)
	end

	if self.overloadShadow then
		shadowPos = playerPos + Vector.New(-10.0,0.0)
		playerY = (137 + playerPos[2])
		playerX = playerY / 800
		playerY = playerY / 400
		DrawTexture(shadowTex, shadowPos[1], -137, 0, self.shadowSize[1] - (playerY * 2), self.shadowSize[2] - playerY, 0.5)
	end
end

function BoneDragon.OverridePosition()
	if(renderAngle[1] == nil or renderPos[1] == nil)then
		return 0,0,0,false
	end

	playerAngle = Wrap(renderAngle[1], -180.0, 180.0)
	final = RenderPosition(renderPos[1], playerOffset, math.rad(-playerAngle))
	return final[1], final[2], playerAngle/2, true
end

function BoneDragon.GetComponentPos(idx)
	if(idx == 0)then
		playerPos = Vector.New(GetPlayerPosition())
		headPos = playerPos + RotateVector(Vector.New(20.0, 5.0), math.rad(headRot))
		return headPos[1], headPos[2]
	elseif(renderPos[idx] ~= nil)then
		return renderPos[idx][1], renderPos[idx][2]
	end

	return 0.0, 0.0
end

function BoneDragon.GetPetPosition()
	finalPos = renderPos[2] + RotateVector(flashOffset, math.rad(BoneDragon.GetPetRotation()))
	return finalPos[1], finalPos[2]
end

function BoneDragon:GetPetRotation()
	return Wrap(renderAngle[2], -180.0, 180.0)
end

function BoneDragon.HitRoof()
	Log("HitRoof")
end

function BoneDragon.HitGround()
	--Log("HitGround")
end

function BoneDragon:TouchUp()
	--Log("TouchUp")
	SetParticleEnabled(smashGround, false)
	if diveEffect ~= nil then
		SetParticleEnabled(diveEffect, false)
	end
	SetParticleEnabled(colossatronDust, false)
	SFX.StopSound(colossatronFire or -1,0.5)

	if(isReady)then
		SFX.PlaySound(self.fireStopSfx)
	end
	playFireSound = 0
	if(playGroundSound == 1)then
		SFX.StopSound(groundSound or -1,0.5)
		SFX.PlaySound(self.grindStopSfx)
		playGroundSound = 0
	end

	inputUp = true
	if self.hasHeadAnim then
		PlayAnimation(head, "stop")
	end
end

function BoneDragon:TouchDown()
	--Log("TouchDown")
	if diveEffect ~= nil then
		SetParticleEnabled(diveEffect, true)
	end

	local diveSound
	if self.dragonDiveSfx ~= nil then
		diveSound = math.random(#self.dragonDiveSfx)
		divingSound = SFX.PlaySound(self.dragonDiveSfx[diveSound])
		playingDivingSound = true
	end

	if self.hasHeadAnim then
		PlayAnimation(head, "idle")
	end
	inputUp = false
end

function BoneDragon:Explode()
	Log("Explode")
	exploded = 1
	Level.Freeze( (self.maxExplosions+1) * explosionDelay)

	SFX.StopSound(colossatronFire or -1, 0.5)
	SFX.StopSound(groundSound or -1, 0.5)
	SFX.StopSound(flySound or -1, 0.5)
	SFX.StopSound(diveSound or -1, 0.5)

	SetParticleEnabled(smashGround, false)
	if diveEffect ~= nil then
		SetParticleEnabled(diveEffect, false)
	end	
	SetParticleEnabled(colossatronDust, false)
	SetParticleEnabled(boneDragonSpeed, false)
	if self.hasHeadAnim then
		PlayAnimation(head, "stop")
	end
end

function BoneDragon:SetupFrags()
	playerPos = Vector.New(GetPlayerPosition())
	filePath = "textures/Characters/Vehicles/dragon/"..self.skinName.."/"
	frags = CreateFrags("Dragon/"..self.skinName, playerPos[1], playerPos[2])

	i = 1
	while renderPos[i] ~= nil and component[i] ~= nil do
		offset = renderPos[1] - playerPos
		AddFrag(frags, filePath..self.secondary[component[i]]..".tex", offset[1], offset[2])
		i = i + 1
	end
end

function BoneDragon:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function BoneDragon.GetRenderCount()
	count = 1
	while renderPos[count] ~= nil do
		count = count + 1
	end

	return count
end

function BoneDragon.GetTailCount()
	return pieceCount
end

function BoneDragon.SaveRenderPosition(idx)
	if idx == 0 then
		playerPos = Vector.New(GetPlayerPosition())
		headPos = playerPos + RotateVector(Vector.New(30.0, 5.0), math.rad(headRot))
		rot = headRot
		return headPos[1], headPos[2], rot
	else
		x, y = BoneDragon.GetComponentPos(idx)
		rot = renderAngle[idx]
		return x, y, rot
	end
end

function BoneDragon.SaveTailPosition(idx)
	idx = idx + 1
	return tailPos[idx][1], tailPos[idx][2]
end

function BoneDragon.LoadRenderPosition(idx, x, y, rot)
	if idx == 0 then
		headPos = Vector.New(x, y)
		headRot = rot
	else
		renderPos[idx] = Vector.New(x, y)
		renderAngle[idx] = rot
	end
end

function BoneDragon.LoadTailPosition(idx, x, y)
	idx = idx + 1
	tailPos[idx] = Vector.New(x, y)

	if idx > pieceCount then
		pieceCount = idx
	end
end


-- Custom Dragon functions

function Wrap(num, minimum, maximum)
	if(num < minimum)then
		return (maximum + 1) - (minimum - num)
	elseif(num > maximum)then
		return minimum + (num - (maximum + 1))
	end

	return num
end

function BoneDragon:CalculateRenderPositions()
	playerPos = Vector.New(GetPlayerPosition())
	levelPos = Vector.New(Level.GetOffset())
	lastPos = playerPos - levelPos
	lastRender = Vector.Clone(lastPos)
	
	offset = 6.0
	renderPos[1] = playerPos + Vector.New(-1,0)
	renderIdx = 2
	for i = 1, pieceCount, 1 do
		pos = Vector.New(lastPos[1] - 4.0, tailPos[i][2])
		diff = pos - lastRender
		diff, mag = Vector.Normalise(diff)
		thisOverlap = self.renderPosOverlap
		if(renderIdx == 2)then
			thisOverlap = self.renderPosOverlap + offset
		end

		if(i == 1 or mag >= thisOverlap)then
			newRenderPos = lastRender + (diff * thisOverlap)
			rp = newRenderPos + levelPos
			texSize = Vector.New(GetTextureSize(blue))
			local screenSize = Vector.New(GetScreenSize())
			if(rp[1] + texSize[1] >= -(screenSize[1]/2))then
				if(rp[2] < -(colDist - (colScale[2]/2.0)))then
					rp = Vector.New(rp[1], -(colDist - (colScale[2]/2.0)))
				end
				renderPos[renderIdx] = rp
				renderIdx = math.min(renderIdx + 1, renderCount-1)
			end

			lastRender = Vector.Clone(newRenderPos)
		end

		lastPos = Vector.Clone(pos)
	end
	rightPivot = Vector.New(7.0, -1.0)
	for i = 1, renderIdx-2, 1 do
		diff = renderPos[i] - renderPos[i+1]
		diff, mag = Vector.Normalise(diff)
		rot = -(math.atan2(diff[1], diff[2]) - (math.pi/2))
		if(i == 1)then
			extraOffset = Vector.New(offset)
			renderPos[i] = RenderPosition(renderPos[i], rightPivot + extraOffset, rot)
		else
			diff = renderPos[i-1] - renderPos[i]
			diff, mag = Vector.Normalise(diff)
			rot2 = -(math.atan2(diff[1], diff[2]) - (math.pi/2))
			rot = (rot + rot2) / 2
			renderPos[i] = RenderPosition(renderPos[i], rightPivot, rot)
		end

		renderAngle[i] = Wrap(math.deg(rot), 0.0, 359.0)
	end
	diff = Vector.New()
	if(renderPos[2] ~= nil)then
		diff = renderPos[1] - renderPos[2]
	end
	headRot = math.deg(math.atan2(diff[2], diff[1]))
	headRot = headRot / 2
end

function RenderPosition(pos, offset, rot)
	x = pos[1] - (math.cos(rot) * offset[1]) - (math.sin(rot) * offset[2])
	y = pos[2] - (math.sin(rot) * offset[1]) - (math.cos(rot) * offset[2])
	retVec = Vector.New(x, y)
	return retVec;
end

function RotateVector(vec, rot)
	x = math.cos(rot) * vec[1] - math.sin(rot) * vec[2];
	y = math.sin(rot) * vec[1] + math.cos(rot) * vec[2];
	retVec = Vector.New(x, y)
	return retVec;
end

function RotateOffset(orig, pos, rot)
	offset = pos - orig
	offset = RotateVector(offset, rot)
	pos = orig + offset
	return pos
end

function BoneDragon:UpdateInputUp(playerPos, dt)
	if(inputVel[2] < 0)then
		if(playerPos[2] <= -(colDist - (colScale[2]*0.5)))then
			inputVel[2] = 0.0
			currentY = playerPos[2] + amp
			angle = 270.0
		elseif(math.abs(inputVel[2]) > pullUpAdditive)then
			inputVel[2] = inputVel[2] - Sign(inputVel[2]) * pullUpAdditive
		else
			inputVel[2] = 0.0
			currentY = playerPos[2] + amp
			angle = 270.0
		end
		inputVel[1] = inputVel[1] / easeInDist
		playerPos = playerPos + (inputVel * (60 * dt))
	else
		inputVel[1] = 0.0
		maximum = roofHeight - amp
		dy = maximum - currentY
		if(dy > returnRoofVel * easeInDist)then
			inputVel[2] = math.min(inputVel[2] + returnRoofAdditive, returnRoofVel)
			OffsetEverything(inputVel[2]*60.0*dt)
		else
			OffsetEverything((dy/easeInDist)*60*dt)
			inputVel[2] = 0.0
		end
		angle = Wrap(angle + sinSpeed, 0.0, 359.0)
		playerPos[2] = currentY + (math.sin(math.rad(angle)) * amp)
	end

	if (playingflySound == false) then
		if (string.len(self.flyLpSfx) > 0) then
			flySound = SFX.PlaySound(self.flyLpSfx, true)
			playingflySound = true

			if self.dragonDiveSfx ~= nil and playingDivingSound == true then
				SFX.StopSound(divingSound, self.flyLpFadeOut)
			end

		end
	end

	dirty = false
	return playerPos
end

function BoneDragon:UpdateInputDown(playerPos, dt)
	if(dirty == false)then
		inputVel[2] = tailPos[1][2] - tailPos[2][2]
	end

	dx = (maxXPos - playerPos[1]) / xEaseInDist
	if(math.abs(dx) > xVel)then
		inputVel[1] = math.min(inputVel[1] + (xVel/xEaseInDist), xVel)
		playerPos[1] = playerPos[1] + inputVel[1]
	else
		inputVel[1] = math.max(inputVel[1] - (xVel/xEaseInDist), 0.0)
		playerPos[1] = playerPos[1] + inputVel[1]
	end

	inputVel[2] = math.max(inputVel[2] - diveAdditive, -maxYVel)
	playerPos[2] = playerPos[2] + (inputVel[2] * (60.0 * dt))
	currentY = currentY + (inputVel[2] * (60.0 * dt))



		-- hit ground effects

	if(playerPos[2] <= -(colDist - (colScale[2]*1.0)))then

		if(playGroundSound == 0)then
			groundSound = SFX.PlaySound(self.grindLpSfx,true)
			playGroundSound = 1
			SetParticleEnabled(smashGround, true)
			SetParticleEnabled(colossatronDust, true)
			if self.hasHeadAnim then
				PlayAnimation(head, "idle")
			end
			Log("velocity: "..inputVel[2])
			if(inputVel[2] <= impactThreshold)then
				SFX.PlaySound(self.dragonLandHardSfx)
			end
		end
	end

	if (playingflySound == true) then
		SFX.StopSound(flySound or -1, self.flyLpFadeOut)
		playingflySound = false
	end

	if(playerPos[2] <= -(colDist - (colScale[2]*0.5)))then
		if(inputVel[2] < impactThreshold)then
			Level.ScreenShake(0.2)

			playerPos = Vector.New(GetPlayerPosition())
			worldPos = Vector.New(Level.GetOffset())
			headPos = playerPos + RotateVector(Vector.New(36.0, 5.0), math.rad(headRot))
			headPos = RotateOffset(headPos + headOffset, headPos, (-jawRot/2))
			local screenSize = Vector.New(GetScreenSize())
			headPos = headPos + (screenSize * 0.5)
			headPos[1] = headPos[1] - 23

			left   = headPos[1] - 32;
			right  = headPos[1] + 32;
			bottom = headPos[2] - 24;
			top    = headPos[2] + 24;
			CollideWithDestructables(left, right, bottom, top)
		end

		inputVel[2] = 0.0
		currentY = playerPos[2] + amp
		angle = 270.0
		headRot = 0.0
	end

	dirty = true
	return playerPos
end

function UpdateFinalPosition(playerPos, dt)
	if(playerPos[2] <= -(colDist - (colScale[2]*0.5)))then
		playerPos[2] = -(colDist - (colScale[2]*0.5))
	else
		if(playerPos[2] > roofHeight)then
			playerPos[2] = roofHeight
		end
	end

	playerPos = playerPos + (velocity * (60.0 * dt))
	if(playerPos[1] > maxXPos)then
		dx = -(playerPos[1] - maxXPos) / xEaseInDist
		playerPos[1] = playerPos[1] + dx
	end

	if(dirty == false)then
		dx = -(playerPos[1] - minRestPos) / xEaseInDist
		if(math.abs(dx) > xReturnSpeed)then
			xReturnVel = math.min(xReturnVel + (xReturnSpeed / xEaseInDist), xReturnSpeed)
			playerPos[1] = playerPos[1] + (Sign(dx) * xReturnVel * 60.0 * dt)
		else
			xReturnVel = 0.0
			playerPos[1] = playerPos[1] + dx
		end
	else
		xReturnVel = 0
	end

	return playerPos
end

function OffsetEverything(dt)
	offset = dt * 0.5
	for i = 1, pieceCount, 1 do
		tailPos[i][2] = tailPos[i][2] + offset
	end

	currentY = currentY + dt
end

function PrintRenderPositions()
	Log("Current Render positions:")
	for i = 1, renderCount, 1 do
		if(renderPos[i] ~= nil)then
			Log(i..": "..renderPos[i][1]..", "..renderPos[i][2])
		end
	end
end

function Sign(x)
	if(x > 0)then
		return 1
	elseif(x < 0)then
		return -1
	else
		return 0
	end
end

function Clamp(val, minimum, maximum)
	if(val > maximum)then
		return maximum
	elseif(val < minimum)then
		return minimum
	else
		return val
	end
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

RegisterVehicle("BoneDragon", "Dragon", BoneDragon);