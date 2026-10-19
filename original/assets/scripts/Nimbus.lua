Log("Nimbus Lua script started")

local Nimbus = {}
local red
local blue
local purple
local orange
local yellow
local green
local head
local jaw
local jawRot
local jawSpeed
local jawOffset
local headOffset
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
local nimbusParticles
local nimbusClouds
local nimbusDust
local nimbusExplosion
local headRot
local maxExplosions
local explosions
local exploded
local explosionDelay
local explosionTimer
local dampening

local primary = {"Nimbus"}
local primaryTex
local shadowTex
local shadowSizeX
local shadowSizeY

local randComponents
local maxComponents
local component

local isReady
local hasHitGround
local impactThreshold

local smokeLifeTime
local friction
local fricDelay

-- SOUNDS

local nimbusSoundActive = -1
local playingNimbusSoundActive = false

local nimbusSound = -1
local playingNimbusSound = false

local nimbusSlide = -1
local playingNimbusSlide = false

-- Function forward declares
local InitVars
local SetupFrags
local Wrap
local CalculateRenderPositions
local RenderPosition
local RotateVector
local RotateOffset
local UpdateInputUp
local UpdateInputDown
local UpdateFinalPosition
local OffsetEverything
local PrintRenderPositions
local Sign
local Clamp
local LogVec

function Nimbus.GetTextureList()
	return "textures/Characters/Vehicles/dragon/Nimbus/Nimbus.tex|/textures/Characters/Vehicles/dragon/Nimbus/NimbusPiece1.tex|/textures/Characters/Vehicles/dragon/Nimbus/NimbusPiece2.tex"
end

function Nimbus:ComponentComplete()
	--Log("Component!")
	componentSound = math.random(3)

	if(componentSound == 1)then
		SFX.PlaySound("nimbus_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("nimbus_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("nimbus_form_3")	
	end
	componentSound = 0
end

function Nimbus:ConstructionComplete()
	--Log("Construction!")
	SFX.PlaySound("nimbus_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function InitVars()
	OverloadPickupSounds()
	OverloadVehicleSounds()
	OverloadVehicleShadow()

	playingNimbusSoundActive = false
	playingNimbusSound = false
	playingNimbusSlide = false
	dampening = 3.0
	jawRot = 0.0
	jawSpeed = 3.5
	jawOffset = Vector.New(-9.0, 3.0)
	headOffset = Vector.New(-20.0, 0.0)
	maxJawRot = 0.8
	tailPos = {}
	renderPos = {}
	renderAngle = {}
	sinSpeed = 5.2
	amp = 6.0
	angle = 0.0
	pieceCount = 8
	renderCount = 18
	renderIdx = 0
	colDist = 137.0
	inputUp = true
	dirty = false
	inputVel = Vector.New(1.0, 0.0)
	velocity = Vector.New(0.0, 0.0)
	playerOffset = Vector.New(0.0, -12.0)
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
	maxExplosions = 1
	explosions = {}
	exploded = 0
	explosionDelay = 0.08
	explosionTimer = 0.0
	hasHitGround = false
	
	shadowSizeX = 2
	shadowSizeY = 1

	primaryTex = {}

	randComponents = false
	maxComponents = 1
	component = {}

	isReady = true

	impactThreshold = -1.0

	friction = 0.95
	fricDelay = 0.0
end

function Nimbus:OnInit(info)
	self.Base.OnInit(self, info)
	
	InitVars()
	filePath = "textures/Characters/Vehicles/dragon/Nimbus/"
	primaryTex[1] = LoadTexture(filePath..primary[1]..".xml", 14)
	primaryTex[2] = LoadTexture(filePath..primary[1]..".xml", 14)
	
	shadowTex = LoadTexture("textures/Effects/effect_shadow.xml",9)
	
	for i = 1, maxExplosions, 1 do
		explosions[i] = LoadTexture("textures/Entities/missileExplosion.xml", 14)
	end
	
	if(randComponents)then
		for i = 1, maxComponents, 1 do
			component[i] = math.random(3)
		end
	else
		for i = 1, maxComponents, 1 do
			component[i] = Wrap(math.ceil(i/2), 1, 3)
		end
	end
	
	nimbusParticles = CreateParticle("nimbus_particles")
	nimbusClouds = CreateParticle("nimbus_clouds")
	nimbusDust = CreateParticle("nimbus_dust")
	nimbusExplosion = CreateParticle("nimbus_explode")
	SetParticleEnabled(nimbusParticles, false)
	SetParticleEnabled(nimbusClouds, false)
	SetParticleEnabled(nimbusDust, false)
	SetParticleEnabled(nimbusExplosion, false)
	
	pos = Vector.New(GetPlayerPosition())
	SetDragonPlayerPosition(pos[1] + 0, pos[2] + 12)
	colScale = Vector.New(18.0, 20.0)
	
	local screenSize = Vector.New(GetScreenSize())
	minRestPos = (screenSize[1]/2) - leftRestPos
	currentY = pos[2]
	a = angle
	
	for i = 1, pieceCount, 1 do
		a = Wrap(a - sinSpeed, 0.0,359.0)
		tailPos[i] = Vector.New(pos[2] - 4.0, currentY + (math.sin(math.rad(a)) * amp))
	end
	
	CalculateRenderPositions()
	ClearPickupComponents()
	AddPickupComponent("textures/Characters/Vehicles/Components/dragon/Nimbus/component1.tex", 16)
	AddPickupComponent("textures/Characters/Vehicles/Components/dragon/Nimbus/component2.tex", 16)
	AddPickupComponent("textures/Characters/Vehicles/Components/dragon/Nimbus/component3.tex", 16)
	AddPickupComponent("textures/Characters/Vehicles/Components/dragon/Nimbus/component4.tex", 16)
	AddPickupComponent("textures/Characters/Vehicles/Components/dragon/Nimbus/component5.tex", 16)
	AddPickupComponent("textures/Characters/Vehicles/Components/dragon/Nimbus/component6.tex", 16)

	SetCollisionOffset(-30.0, 0.0)
end

function Nimbus:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Nimbus:PickupSequenceUpdate(dt)
end

function Nimbus:Ready(skipPickupSeq)
	isReady = true
	SetParticleEnabled(nimbusParticles, true)
	SetParticleEnabled(nimbusClouds, true)
	
	nimbusSound = SFX.PlaySound("nimbus_lp",true)
	playingNimbusSound = true

	VehicleUtils.PlaySong(self, "music", "ready")
end

function Nimbus:OnUpdate(dt)
	playerPos = Vector.New(GetPlayerPosition())
	if(exploded > 0)then
		dt = 0.01666 -- we've frozen the game at this point, so dt is coming through as 0
		explosionTimer = explosionTimer - dt
		if(explosionTimer <= 0.0)then
			if(exploded <= maxExplosions)then
				explosionTimer = explosionDelay
				PlayAnimation(explosions[exploded], "expl")
				exploded = exploded + 1
				SFX.PlaySound("cuddles_explode")
			else
				SetupFrags()
				Level.DisableVehicles()
				CreateEmp(playerPos[1], playerPos[2])
				Level.ForceCoins(1)
				SelfDestruct()
			end
		end
		
		return
	end
	
	velocity = Vector.New(VehicleUpdateSpeed(dt))
	
	for i = pieceCount - 1, 1, -1 do
		tailPos[i+1] = tailPos[i]
	end
	tailPos[1] = Vector.Clone(playerPos)
	
	if(inputUp == true)then
		playerPos = UpdateInputUp(playerPos, dt)
		jawRot = math.min(jawRot + (jawSpeed * dt), 0.0)
	else
		playerPos = UpdateInputDown(playerPos, dt)
		jawRot = math.max(jawRot - (jawSpeed * dt), -maxJawRot)
	end
	
	playerPos = UpdateFinalPosition(playerPos, dt)
	
	SetPlayerPosition(playerPos[1], playerPos[2])
	CalculateRenderPositions()
	
	UpdatePlayerAnim()
	UpdateVehicleParticles()
end

function Nimbus:OnDraw()
	playerPos = Vector.New(GetPlayerPosition())
	worldPos = Vector.New(Level.GetOffset())
	headPos = playerPos + RotateVector(Vector.New(36.0, 5.0), math.rad(headRot))
	headPos = RotateOffset(headPos + headOffset, headPos, (-jawRot/9))
	jawPos = headPos + RotateVector(Vector.New(10.0, -15.0), math.rad(headRot))
	jawPos = RotateOffset(jawPos + jawOffset, jawPos, (jawRot/2))
	nimbusParticlePos = renderPos[1] + Vector.New(-20.0, -3.0)
	nimbusCloudsPos = renderPos[1] + Vector.New(20,-4.0)
	nimbusDustPos = renderPos[1] + Vector.New(30,-100.0)	
	nimbusExplosionPos = renderPos[1] + Vector.New(0,0.0)	
	
	DrawTexture(primaryTex[component[1]], renderPos[1][1], renderPos[1][2], renderAngle[1])

	
	shadowPos = playerPos + Vector.New(10.0,0.0)
	
	playerY = (137 + playerPos[2])
	
	playerX = playerY / 800
	playerY = playerY / 400
	
	DrawTexture(shadowTex, shadowPos[1], -137, 0, shadowSizeX - (playerY * 2), shadowSizeY - playerY, 0.5)
	
	finalNimbusParticlePos = nimbusParticlePos - worldPos
	finalNimbusCloudsPos = nimbusCloudsPos - worldPos
	finalNimbusDustPos = nimbusDustPos - worldPos
	finalNimbusExplosionPos = nimbusExplosionPos - worldPos
	
	SetParticlePosition(nimbusParticles, finalNimbusParticlePos[1], finalNimbusParticlePos[2])
	SetParticlePosition(nimbusClouds, finalNimbusCloudsPos[1], finalNimbusCloudsPos[2])
	SetParticlePosition(nimbusDust, finalNimbusDustPos[1], finalNimbusDustPos[2])
	SetParticlePosition(nimbusExplosion, finalNimbusExplosionPos[1], finalNimbusExplosionPos[2])
	
	if(renderAngle[1] ~= nil)then
		playerAngle = Wrap(renderAngle[1], -180.0, 180.0)
		final = RenderPosition(renderPos[1] - Vector.New(5,0), playerOffset, math.rad(-playerAngle))
		DrawPlayer(final[1], final[2], playerAngle, playerAngle)
	end
end

function Nimbus.OverridePosition()
	playerAngle = Wrap(renderAngle[1], -180.0, 180.0)
	offset = Vector.New(8, 11)
	playerPos = Vector.New(GetPlayerPosition()) + offset
	
	return playerPos[1], playerPos[2], playerAngle/2, true
end

function Nimbus.GetComponentPos(idx)
	playerPos = Vector.New(GetPlayerPosition())
	return playerPos[1], playerPos[2]
end

function Nimbus.GetPetPosition()
	finalPos = renderPos[1] + RotateVector(Vector.New(-18,9), math.rad(Nimbus.GetPetRotation()))
	return finalPos[1], finalPos[2]
end

function Nimbus.GetPetRotation()
	return Wrap(renderAngle[1], -180.0, 180.0)
end

function Nimbus.HitRoof()
	Log("HitRoof")
end

function Nimbus.HitGround()
	--Log("HitGround")
end

function Nimbus:TouchUp()
	Log("TouchUp")

	inputUp = true
end

function Nimbus:TouchDown()
	Log("TouchDown")

	inputUp = false
end

function Nimbus:Explode()
	Log("Explode")
	SetParticleEnabled(nimbusExplosion, true)
	exploded = 1
	SFX.PlaySound("nimbus_explode")	

	Level.Freeze( (maxExplosions+1) * explosionDelay)
	
	SetParticleEnabled(nimbusParticles, false)
	SFX.StopSound(nimbusSoundActive or -1,0.4)
	SFX.StopSound(nimbusSound or -1,0.4)
	SFX.StopSound(nimbusSlide or -1,0.4)
end

function SetupFrags()
	playerPos = Vector.New(GetPlayerPosition())
	filePath = "textures/Characters/Vehicles/dragon/Nimbus/"
	frags = CreateFrags("Dragon/Nimbus", playerPos[1], playerPos[2])
	
	i = 1
	while renderPos[i] ~= nil and component[i] ~= nil do
		offset = renderPos[i] - playerPos
			--AddFrag(frags, filePath..primary[component[1]]..".tex", playerPos[1], playerPos[2])
		i = i + 1
	end
end

function Nimbus:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function Nimbus.GetRenderCount()
	count = 1
	while renderPos[count] ~= nil do
		count = count + 1
	end
	
	return count
end

function Nimbus.GetTailCount()
	return pieceCount
end

function Nimbus.SaveRenderPosition(idx)
	if idx == 0 then
		playerPos = Vector.New(GetPlayerPosition())
		headPos = playerPos + RotateVector(Vector.New(30.0, 5.0), math.rad(headRot))
		rot = headRot
		return headPos[1], headPos[2], rot
	else
		x, y = Nimbus.GetComponentPos(idx)
		rot = renderAngle[idx]
		return x, y, rot
	end
end

function Nimbus.SaveTailPosition(idx)
	idx = idx + 1
	return tailPos[idx][1], tailPos[idx][2]
end

function Nimbus.LoadRenderPosition(idx, x, y, rot)
	if idx == 0 then
		headPos = Vector.New(x, y)
		headRot = rot
	else
		renderPos[idx] = Vector.New(x, y)
		renderAngle[idx] = rot
	end
end

function Nimbus.LoadTailPosition(idx, x, y)
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

function CalculateRenderPositions()
	playerPos = Vector.New(GetPlayerPosition())
	levelPos = Vector.New(Level.GetOffset())
	lastPos = playerPos - levelPos
	lastRender = Vector.Clone(lastPos)
	
	
	overlap = 1
	offset = 6.0
	renderPos[1] = playerPos + Vector.New(25,0)
	renderIdx = 2
	for i = 1, pieceCount, 1 do
		pos = Vector.New(lastPos[1] - 4.0, tailPos[i][2])
		diff = pos - lastRender
		diff, mag = Vector.Normalise(diff)
		thisOverlap = overlap
		if(renderIdx == 2)then
			thisOverlap = overlap + offset
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
		
		renderAngle[i] = Wrap(math.deg(rot)/dampening, 0.0, 359.0)
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

function UpdateInputUp(playerPos, dt)
	if(playingNimbusSoundActive == true)then
		SFX.StopSound(nimbusSoundActive or -1,0.4)
		playingNimbusSoundActive = false
	end	
	if(playingNimbusSound == false)then
		nimbusSound = SFX.PlaySound("nimbus_lp", true)
		playingNimbusSound = true
	end
	if(playingNimbusSlide == true)then
		SFX.StopSound(nimbusSlide or -1,0.4)
		playingNimbusSlide = false
	end
	if(hasHitGround == true)then
		hasHitGround = false
		PlayAnimation(primaryTex[component[1]], "idle")
		SetParticleEnabled(nimbusDust, false)
	end
	--Log("Update Input Up")
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
	dirty = false
	return playerPos
end

function UpdateInputDown(playerPos, dt)
	if(playingNimbusSound == true)then
		Log("Touch Down play nimbus_active_lp")
		SFX.StopSound(nimbusSound or -1,0.4)
		playingNimbusSound = false
	end
	if(playingNimbusSoundActive == false and playingNimbusSlide == false)then
		nimbusSoundActive = SFX.PlaySound("nimbus_active_lp", true)
		playingNimbusSoundActive = true
	end
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
		Log("hitGround!")
		if(hasHitGround == false)then
			hasHitGround = true
			PlayAnimation(primaryTex[component[1]], "land")
			Log("enableParticle!!")
			SetParticleEnabled(nimbusDust, true)
			Log("velocity: "..inputVel[2])
			if(inputVel[2] <= impactThreshold)then
				SFX.PlaySound("nimbus_land")
				if(playingNimbusSoundActive == true)then
					SFX.StopSound(nimbusSoundActive or -1,0.4)
					playingNimbusSoundActive = false

				end	
				if(playingNimbusSlide == false)then
					playingNimbusSlide = true
					nimbusSlide = SFX.PlaySound("duck_slide_lp",true)
				end
			end
		else
			--SetParticleEnabled(nimbusDust, false)
		end
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

RegisterVehicle("Nimbus", "Dragon", Nimbus);