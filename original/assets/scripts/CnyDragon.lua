Log("CnyDragon Lua script started")

local CnyDragon = {}

local head
local jaw
local jawRot
local jawSpeed
local jawOffset
local jawPos
local headOffset
local randComponents
local primary = {"dragonBodySaddle"}
local secondary = { "dragonBody","dragonBody","dragonBody","dragonBody"}
local maxComponents
local component
local tailPos
local maxExplosions
local explosions
local minRestPos
local leftRestPos
local pieceCount
local sinSpeed
local renderPos
local renderCount
local headRot
local headPos
local angle
local amp
local colDist
local colScale

local Wrap
local RenderPosition

function CnyDragon.GetTextureList()
	return "textures/Characters/Vehicles/dragon/CnyDragon/dragonBodySaddle.tex|textures/Characters/Vehicles/dragon/CnyDragon/dragonBody.tex|textures/Characters/Vehicles/dragon/CnyDragon/dragonHead.tex|textures/Characters/Vehicles/dragon/CnyDragon/dragonHorn.tex|textures/Characters/Vehicles/dragon/CnyDragon/dragonJaw.tex|textures/Characters/Vehicles/dragon/CnyDragon/dragonNose.tex"
end

function InitVars()

	jawRot = 0.0
	jawSpeed = 3.5
	jawOffset = Vector.New(3.0, -3.0)
	headOffset = Vector.New(0.0, 0.0)
	maxJawRot = 0.6
	randComponents = false
	maxComponents = 6
	component = {}
	maxExplosions = 1
	explosions = {}
	leftRestPos = 397.0
	pieceCount = 8
	sinSpeed = 5.2
	renderPos = {}
	headRot = 0.0
	tailPos = {}
	angle = 0.0
	amp = 6.0
	colDist = 135.0
	renderCount = 18

end

function CnyDragon:OnInit(info)

	Log("CnyDragon init")
	self.Base.OnInit(self, info)

	InitVars()
	
	filePath = "textures/Characters/Vehicles/dragon/CnyDragon/"

	SetJawPositionOffset(jawOffset[1], jawOffset[2]);
	Log("Jaw offset set")


	if(randComponents)then
		for i = 1, maxComponents, 1 do
			component[i] = math.random(3)
		end
	else
		for i = 1, maxComponents, 1 do
			component[i] = Wrap(math.ceil(i/2), 1, 3)
		end
	end

	Log("Setting up textures")

	head = LoadTexture(filePath.."DragonHead.xml", 12)
	jaw = LoadTexture(filePath.."DragonJaw.xml", 12)
	backHornTex = LoadTexture("textures/Characters/Vehicles/dragon/CnyDragon/backHorn.xml", 7)
	glowingEyeTex = LoadTexture("textures/Characters/Vehicles/dragon/CnyDragon/glowingEye.xml", 12)
	for i = 1, maxExplosions, 1 do
		explosions[i] = LoadTexture("textures/Entities/missileExplosion.xml", 12)
	end

	Log("Setting up particles")

	smashGround = CreateParticle("Colossatron_crash")
	colossatronDust = CreateParticle("colossatron_dust_cloud")
	boneDragonSpeed = CreateParticle("BoneDragon_speed")
	SetParticleEnabled(smashGround, false)
	SetParticleEnabled(colossatronDust, false)
	SetParticleEnabled(boneDragonSpeed, true)
	noseFlame = CreateParticle("Bone_Dragon_Nose")
	SetParticleEnabled(noseFlame, false)

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
	AddPickupComponent("textures/Characters/Vehicles/Components/Dragon/CnyDragon/component1.tex", 16)
	Log("adding Component")
	AddPickupComponent(filePath..primary[1]..".tex", 9)
	Log("adding Component")
	i = 2

	while renderPos[i] and secondary[i] do
		AddPickupComponent(filePath..secondary[component[i]]..".tex", 9)
		Log("adding Component")
		i = i + 1
	end
end

function CnyDragon:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function CnyDragon.ComponentComplete()
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

function CnyDragon:ConstructionComplete()
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function CnyDragon:Ready(skipPickupSeq)
	VehicleUtils.PlaySong(self, "music", "ready")
end

function CnyDragon:OnDraw()

	self.Base.OnDraw(self)

	playerPos = Vector.New(GetPlayerPosition())
	headPos = playerPos + RotateVector(Vector.New(36.0, 5.0), math.rad(headRot))
	headPos = RotateOffset(headPos + headOffset, headPos, (-jawRot/2))
	jawPos = headPos + RotateVector(Vector.New(10.0, -15.0), math.rad(headRot))
	jawPos = RotateOffset(jawPos + jawOffset, jawPos, (jawRot/2))

	DrawTexture(jaw, jawPos[1], jawPos[2], headRot + math.deg(jawRot/2) )

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

function RenderPosition(pos, offset, rot)
	x = pos[1] - (math.cos(rot) * offset[1]) - (math.sin(rot) * offset[2])
	y = pos[2] - (math.sin(rot) * offset[1]) - (math.cos(rot) * offset[2])
	retVec = Vector.New(x, y)
	return retVec;
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

	end
	diff = Vector.New()
	if(renderPos[2] ~= nil)then
		diff = renderPos[1] - renderPos[2]
	end
	headRot = math.deg(math.atan2(diff[2], diff[1]))
	headRot = headRot / 2
end

function CnyDragon.PickupSequenceUpdate(dt)
end

function CnyDragon:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function CnyDragon.GetRenderCount()
	count = 1
	while renderPos[count] ~= nil do
		count = count + 1
	end

	return count
end

RegisterVehicle("CnyDragon", "Dragon", CnyDragon);
