Log("Colossatron Lua script started")

local Colossatron = {}
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
local colossatronFire
local colossatronSpeed
local colossatronDust
local headRot
local maxExplosions
local explosions
local exploded
local explosionDelay
local explosionTimer

local primary = {"Blue", "Yellow", "Red"}
local primaryTex
local secondary = {"Green", "Orange", "Purple"}
local secondaryTex

local randComponents
local maxComponents
local component

local isReady
local groundSound
local playGroundSound
local impactThreshold
local playFireSound

local fireTimer
local rateOfFire
local randFireAngle
local minFireVel
local maxFireVel
local fireLifeTime
local smokeLifeTime
local friction
local fricDelay

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

function Colossatron.GetTextureList()
	return "textures/Characters/Vehicles/dragon/Colossatron/Blue.tex|textures/Characters/Vehicles/dragon/Colossatron/Yellow.tex|textures/Characters/Vehicles/dragon/Colossatron/Red.tex|textures/Characters/Vehicles/dragon/Colossatron/Green.tex|textures/Characters/Vehicles/dragon/Colossatron/Orange.tex|textures/Characters/Vehicles/dragon/Colossatron/Purple.tex|textures/Characters/Vehicles/dragon/Colossatron/DragonHead.tex|textures/Characters/Vehicles/dragon/Colossatron/DragonJaw.tex"
end

local function UpdateBreatheFire(dt)
	fireTimer = fireTimer - dt
	playerPos = Vector.New(GetPlayerPosition())
	if(fireTimer < 0.0 and inputUp ~= true and jawRot <= (-maxJawRot + 0.4))then
	
		if(playFireSound == 0)then
			colossatronFire = SFX.PlaySound("colossatron_fire_lp",true)
			playFireSound = 1
		end
	
		fireAngle = headRot + 90.0
		fireAngle = fireAngle + (math.random(randFireAngle*2)-randFireAngle)
		vel = minFireVel + ((math.random(100)/100) * (maxFireVel-minFireVel))
		velocity = Vector.New(math.sin(math.rad(fireAngle)) * vel, -math.cos(math.rad(fireAngle)) * vel)
		spawnPos = RenderPosition(playerPos, Vector.New(-28.0, 0.0), math.rad(headRot))
		
		BreathFire(spawnPos[1], spawnPos[2], velocity[1], velocity[2], fireLifeTime, friction, fricDelay, true)
		BreathFire(spawnPos[1], spawnPos[2], velocity[1], velocity[2], smokeLifeTime, friction, fricDelay, false)
		
		fireTimer = rateOfFire
	end
end

function Colossatron.ComponentComplete()
	Log("Component!")
	componentSound = math.random(4)

	if(componentSound == 1)then
		SFX.PlaySound("colossatron_form_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("colossatron_form_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("colossatron_form_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("colossatron_form_4")			
	end
	componentSound = 0
end

function Colossatron:ConstructionComplete()
	Log("Construction!")
	SFX.PlaySound("colossatron_form_complete")
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function InitVars()
	OverloadPickupSounds()
	OverloadVehicleSounds()

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
	pieceCount = 128
	renderCount = 19
	renderIdx = 0
	colDist = 135.0
	inputUp = true
	dirty = false
	inputVel = Vector.New(1.0, 0.0)
	velocity = Vector.New(0.0, 0.0)
	playerOffset = Vector.New(0.0, -20.0)
	pullUpAdditive = 0.2
	roofHeight = 100.0
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
	maxExplosions = 4
	explosions = {}
	exploded = 0
	explosionDelay = 0.10
	explosionTimer = 0.0

	primaryTex = {}
	secondaryTex = {}

	randComponents = false
	maxComponents = 11
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

function Colossatron:OnInit(info)
	self.Base.OnInit(self, info)
	Log("Colossatron init")
	
	InitVars()
	
	filePath = "textures/Characters/Vehicles/dragon/Colossatron/"
	primaryTex[1] = LoadTexture(filePath..primary[1]..".xml", 11)
	primaryTex[2] = LoadTexture(filePath..primary[2]..".xml", 11)
	primaryTex[3] = LoadTexture(filePath..primary[3]..".xml", 11)
	secondaryTex[1] = LoadTexture(filePath..secondary[1]..".xml", 11)
	secondaryTex[2] = LoadTexture(filePath..secondary[2]..".xml", 11)
	secondaryTex[3] = LoadTexture(filePath..secondary[3]..".xml", 11)
	head = LoadTexture(filePath.."DragonHead.xml", 12)
	jaw = LoadTexture(filePath.."DragonJaw.xml", 12)
	
	for i = 1, maxExplosions, 1 do
		explosions[i] = LoadTexture("textures/Entities/missileExplosion.xml", 12)
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
	
	smashGround = CreateParticle("Colossatron_crash")
	colossatronSpeed = CreateParticle("Colossatron_speed")
	colossatronDust = CreateParticle("colossatron_dust_cloud")
	SetParticleEnabled(smashGround, false)
	SetParticleEnabled(colossatronSpeed, false)
	SetParticleEnabled(colossatronDust, false)
	
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
	
	CalculateRenderPositions()
	ClearPickupComponents()
	AddPickupComponent("textures/Characters/Vehicles/Components/Dragon/Colossatron/component1.tex", 16)
	
	i = 1
	while renderPos[i] do
		--Log("renderPos hit!")
		if(i%2 == 0)then
			AddPickupComponent(filePath..secondary[component[i]]..".tex", 16)
		else
			AddPickupComponent(filePath..primary[component[i]]..".tex", 16)
		end
		i = i + 1
	end
	
	SetCollisionOffset(-30.0, 3.0)
end

function Colossatron:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function Colossatron.PickupSequenceUpdate(dt)
	--Log("PickupSequenceUpdate")
end

function Colossatron:Ready(skipPickupSeq)
	Log("Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
	isReady = true
	SetParticleEnabled(colossatronSpeed, true)
end

function Colossatron:OnUpdate(dt)
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
	
	UpdateBreatheFire(dt)
	UpdatePlayerAnim()
	UpdateVehicleParticles()
end

function Colossatron:OnDraw()
	playerPos = Vector.New(GetPlayerPosition())
	worldPos = Vector.New(Level.GetOffset())
	headPos = playerPos + RotateVector(Vector.New(36.0, 5.0), math.rad(headRot))
	headPos = RotateOffset(headPos + headOffset, headPos, (-jawRot/2))
	jawPos = headPos + RotateVector(Vector.New(10.0, -15.0), math.rad(headRot))
	jawPos = RotateOffset(jawPos + jawOffset, jawPos, (jawRot/2))
	rubblePos = headPos + Vector.New(35.0, -30.0)
	dustPos = headPos + Vector.New(0.0, -20.0)
	speedPos = headPos + Vector.New(5.0, -4.0)
	
	DrawTexture(head, headPos[1], headPos[2], headRot - math.deg(jawRot/2))
	DrawTexture(jaw, jawPos[1], jawPos[2], headRot + math.deg(jawRot/2) )
	
	for i = 1, maxComponents, 1 do
		if(renderPos[i] ~= nil)then
			if(i%2 == 0)then
				DrawTexture(secondaryTex[component[i]], renderPos[i][1], renderPos[i][2], renderAngle[i])
			else
				DrawTexture(primaryTex[component[i]], renderPos[i][1], renderPos[i][2], renderAngle[i])
			end
			
			if(i <= exploded)then
				DrawTexture(explosions[i], renderPos[i][1], renderPos[i][2], renderAngle[i])
			end
		end
	end
	
	finalRubblePos = rubblePos - worldPos
	finalSpeedPos = speedPos - worldPos
	
	SetParticlePosition(smashGround, finalRubblePos[1], finalRubblePos[2])
	SetParticlePosition(colossatronDust, dustPos[1], dustPos[2])
	SetParticlePosition(colossatronSpeed, finalSpeedPos[1], finalSpeedPos[2])
	
	if(renderAngle[1] ~= nil)then
		playerAngle = Wrap(renderAngle[1], -180.0, 180.0)
		final = RenderPosition(renderPos[1], playerOffset, math.rad(-playerAngle))
		DrawPlayer(final[1], final[2], playerAngle/2, playerAngle/2)
	end
end

function Colossatron.OverridePosition()
	if(renderAngle[1] == nil or renderPos[1] == nil)then
		return 0,0,0,false
	end
	
	playerAngle = Wrap(renderAngle[1], -180.0, 180.0)
	final = RenderPosition(renderPos[1], playerOffset, math.rad(-playerAngle))
	return final[1], final[2], playerAngle/2, true
end

function Colossatron.GetComponentPos(idx)
	if(idx == 0)then
		playerPos = Vector.New(GetPlayerPosition())
		headPos = playerPos + RotateVector(Vector.New(30.0, 5.0), math.rad(headRot))
		return headPos[1], headPos[2]
	elseif(renderPos[idx] ~= nil)then
		return renderPos[idx][1], renderPos[idx][2]
	end
	
	return 0.0, 0.0
end

function Colossatron.GetPetPosition()
	finalPos = renderPos[2] + RotateVector(Vector.New(0,22), math.rad(Colossatron.GetPetRotation()))
	return finalPos[1], finalPos[2]
end

function Colossatron.GetPetRotation()
	return Wrap(renderAngle[2], -180.0, 180.0)
end

function Colossatron.HitRoof()
end

function Colossatron.HitGround()
end

function Colossatron.TouchUp()
	Log("Colossatron.TouchUp()")
	SetParticleEnabled(smashGround, false)
	SetParticleEnabled(colossatronDust, false)
	SFX.StopSound(colossatronFire or -1,0.5)
	
	if(isReady)then
		SFX.PlaySound("colossatron_fire_stop")
	end
	playFireSound = 0
	if(playGroundSound == 1)then
		SFX.StopSound(groundSound or -1,0.5)
		SFX.PlaySound("colossatron_grind_stop")
		playGroundSound = 0
	end

	inputUp = true
end

function Colossatron.TouchDown()
	Log("Colossatron.TouchDown()")
	inputUp = false
end

function Colossatron.Explode()
	exploded = 1
	Level.Freeze( (maxExplosions+1) * explosionDelay)
	
	SFX.StopSound(colossatronFire or -1,0.5)
	SFX.StopSound(groundSound or -1,0.5)
	
	SetParticleEnabled(smashGround, false)
	SetParticleEnabled(colossatronDust, false)
	SetParticleEnabled(colossatronSpeed, false)
end

function SetupFrags()
	playerPos = Vector.New(GetPlayerPosition())
	filePath = "textures/Characters/Vehicles/dragon/Colossatron/"
	frags = CreateFrags("Dragon/Colossatron", playerPos[1], playerPos[2])

	i = 1
	while renderPos[i] ~= nil and component[i] ~= nil do
		offset = renderPos[1] - playerPos
		AddFrag(frags, filePath..secondary[component[i]]..".tex", offset[1], offset[2])
		i = i + 1
	end
end

function Colossatron:OnDestroy()
	Log("Colossatron:OnDestroy()")

	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function Colossatron.GetRenderCount()
	count = 1
	while renderPos[count] ~= nil do
		count = count + 1
	end
	
	return count
end

function Colossatron.GetTailCount()
	return pieceCount
end

function Colossatron.SaveRenderPosition(idx)
	if idx == 0 then
		playerPos = Vector.New(GetPlayerPosition())
		headPos = playerPos + RotateVector(Vector.New(30.0, 5.0), math.rad(headRot))
		rot = headRot
		return headPos[1], headPos[2], rot
	else
		x, y = Colossatron.GetComponentPos(idx)
		rot = renderAngle[idx]
		return x, y, rot
	end
end

function Colossatron.SaveTailPosition(idx)
	idx = idx + 1
	return tailPos[idx][1], tailPos[idx][2]
end

function Colossatron.LoadRenderPosition(idx, x, y, rot)
	if idx == 0 then
		headPos = Vector.New(x, y)
		headRot = rot
	else
		renderPos[idx] = Vector.New(x, y)
		renderAngle[idx] = rot
	end
end

function Colossatron.LoadTailPosition(idx, x, y)
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
	
	overlap = 37.5
	offset = 6.0
	renderPos[1] = playerPos
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

function UpdateInputUp(playerPos, dt)
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
			groundSound = SFX.PlaySound("colossatron_grind_lp",true)
			playGroundSound = 1
			SetParticleEnabled(smashGround, true)
			SetParticleEnabled(colossatronDust, true)
			Log("velocity: "..inputVel[2])
			if(inputVel[2] <= impactThreshold)then
				SFX.PlaySound("mech_land")
			end
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

RegisterVehicle("Colossatron", "Dragon", Colossatron);