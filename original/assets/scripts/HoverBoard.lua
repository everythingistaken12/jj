Log("HoverBoard Lua script started v1.1.22")

local Constants =
{
	JumpVelStart = 330.0,
	JumpVelEnd = 370.0,
	JumpHeldMax = 0.2,
	DoubleJumpVel = 440.0,

	accelDown = -1050.0,
	maxDown = -830.0,

	roofPos =  116,
	floorPos = -118,
	hoverPos = -110,
	fallHeight = -50
}

---
-- enum HoverBoardState
---
local HoverBoardState =
{
	None = -1,
	Dead = 0,
	Grounded = 1,
	Hovering = 2,
	Jumping = 3,
	Falling = 4,
}

-- The HoverBoard itself
HoverBoard = HoverBoard or {}

HoverBoard.rotation = 0.0
HoverBoard.isTouchHeld = false
HoverBoard.hasDoubleJumped = false
HoverBoard.isTouchingFloor = false
HoverBoard.yVel = 0.0
HoverBoard.jumpHeldTimer = 0.0
HoverBoard.texture = nil

HoverBoard.State = {}
HoverBoard.State.previous = HoverBoardState.None
HoverBoard.State.current = HoverBoardState.None

HoverBoard.Particles = {}
HoverBoard.Particles.Sparks = Particle.new("Spark_Trail", Vector.New(5, -10), ParticleLTWType.LevelRelative)
HoverBoard.Particles.Hover = Particle.new("HoverBoard_Hover", Vector.New(0, -20), ParticleLTWType.LevelRelative)
HoverBoard.Particles.Kickflip = Particle.new("HoverBoard_Kickflip", Vector.New(0, 0), ParticleLTWType.LevelRelative)

HoverBoard.Sounds = {}
-- when the vehicle is finished assembling
HoverBoard.Sounds.Activate = Sound.new("hoverboard_activate")
-- when the vehicle is exploded
HoverBoard.Sounds.Death = Sound.new("hoverboard_death")

-- looping sound for the engine
HoverBoard.Sounds.Engine = Sound.new("hoverboard_lp", true, 1.0)
-- alternating sounds for jumps
HoverBoard.Sounds.Jump1 = Sound.new("hoverboard_jump_1")
HoverBoard.Sounds.Jump2 = Sound.new("hoverboard_jump_2")
HoverBoard.Sounds.Jump3 = Sound.new("hoverboard_jump_3")
-- when the vehicle does a double jump
HoverBoard.Sounds.Kickflip = Sound.new("hoverboard_kickflip")
-- when the vehicle lands from a jump
HoverBoard.Sounds.Land = Sound.new("hoverboard_land")

---
-- DisableAllParticles()
--  Does what it says.
---
function HoverBoard:DisableAllParticles()
	self.Particles.Sparks:SetActive(false)
	self.Particles.Hover:SetActive(false)
end

---
-- StopAllSounds()
--  Does what it says.
---
function HoverBoard:StopAllSounds()
	self.Sounds.Activate:Stop(0.05)
	self.Sounds.Death:Stop(0.05)
	self.Sounds.Engine:Stop(0.05)
	self.Sounds.Jump1:Stop(0.05)
	self.Sounds.Jump2:Stop(0.05)
	self.Sounds.Jump3:Stop(0.05)
	self.Sounds.Kickflip:Stop(0.05)
	self.Sounds.Land:Stop(0.05)
end
---
-- SetState
--  Called when ever you want to change the current HoverBoardState
---
function HoverBoard:SetState(state)
	self.State.previous = HoverBoard.State.current
	self.State.current = state
end

function HoverBoard.GetTextureList()
	return
	"textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component1.tex"..
	"|textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component2.tex"..
	"|textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component3.tex"..
	"|textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component4.tex"
end

function HoverBoard:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

---
-- PickupStart()
--  ???
---
function HoverBoard:PickupStart()
	--Debug.Log(Debug.General, "HoverBoard:PickupStart")
	OffsetPickupComponents(-11,9)
end

---
-- ComponentComplete
--  Called from cpp during construction, when one of the components has snapped in place.
---
function HoverBoard:ComponentComplete()
	--Debug.Log(Debug.General, "HoverBoard:ComponentComplete")
end

---
-- ConstructionComplete()
--  Called from cpp, when the HoverBoard has finished being constructed.
---
function HoverBoard:ConstructionComplete()
	--Debug.Log(Debug.General, "HoverBoard:ConstructionComplete")
	self.Sounds.Activate:Play()
	OffsetVehiclePosition(-12, 0)

	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

---
-- OnInit
--  Called from cpp when the Vehicle has just been Initialized.
--
-- Note: The Vehicle may be drawn before its first update.
--       So, make sure that its state is presentable.
---
function HoverBoard:OnInit(info)
	--Debug.Log(Debug.General, "HoverBoard:OnInit")
	self.Base.OnInit(self, info)

	pos = Vector.New(GetPlayerPosition())

	self.hasDoubleJumped = false
	self.isTouchingFloor = true
	if(pos[2] > Constants.hoverPos)then
		self.isTouchingFloor = false
	end

	self.yVel = 0

	self.texture = LoadTexture("textures/Characters/Vehicles/HoverBoard/HoverBoard/hoverboard.xml", 10)
	if(self.isTouchingFloor == true)then
		self:SetState(HoverBoardState.Hovering)
		PlayAnimation(self.texture, "skate")
	else
		self:SetState(HoverBoardState.Falling)
		PlayAnimation(self.texture, "fall")
	end

	SetVehicleScreenShotRating(50)
	self:SetDrawHead(false)
end

---
-- PickupSequenceUpdate()
--  ???
---
function HoverBoard:PickupSequenceUpdate(dt)
	--Debug.Log(Debug.General, "HoverBoard:PickupSequenceUpdate")
end

---
-- Ready()
--  ???
---
function HoverBoard:Ready(skipPickupSeq)
	--Debug.Log(Debug.General, "HoverBoard:Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
end

---
-- OnUpdate(dt)
--  Called from cpp, once per frame.
---
function HoverBoard:OnUpdate(dt)

	if (self.State.current == HoverBoardState.None) then
		self:UpdateStateNone(dt)
	elseif (self.State.current == HoverBoardState.Grounded) then
		self:UpdateStateGrounded(dt)
	elseif (self.State.current == HoverBoardState.Hovering) then
		self:UpdateStateHovering(dt)
	elseif (self.State.current == HoverBoardState.Jumping) then
		self:UpdateStateJumping(dt)
	elseif (self.State.current == HoverBoardState.Falling) then
		self:UpdateStateFalling(dt)
	else
		self:UpdateStateDead(dt)
	end

	self:UpdatePosition(dt)

	self.Particles.Sparks:Update(self)
	self.Particles.Hover:Update(self)
	self.Particles.Kickflip:Update(self)

	-- updates the magnet particles
	UpdateVehicleParticles()


	VehicleUpdateSpeed(dt)

end

---
-- UpdatePosition
--  This handles the movement of the HoverBoard whether it is hovering, jumping, falling..etc
---
function HoverBoard:UpdatePosition(dt)
	local pos = Vector.New(GetPlayerPosition())

	-- gravity
	self.yVel = self.yVel + (Constants.accelDown * dt)

	-- hovering
	if (pos[2] < Constants.hoverPos) then
		-- springyness
		local springDampen = 0.50
		local springConstant = 25
		local springZero = Constants.hoverPos
		local springPos = pos[2]
		local springDisplacement = springPos - springZero
		local springAcceleration = 0.0 - springDisplacement * springConstant
		self.yVel = (self.yVel + springAcceleration) * springDampen
	end

	-- jumping
	if (self.jumpHeldTimer < Constants.JumpHeldMax) then
		self.jumpHeldTimer = self.jumpHeldTimer + dt
		if (self.isTouchHeld == true and self.hasDoubleJumped == false) then
			local time = self.jumpHeldTimer / Constants.JumpHeldMax
			self.yVel = Lerp.Linear.Tween(Constants.JumpVelStart, Constants.JumpVelEnd, time)
		end
	end

	-- clamp velocity
	self.yVel = math.max(Constants.maxDown, self.yVel)
	pos[2] = pos[2] + (self.yVel * dt)

	-- roof check
	if (pos[2] >= Constants.roofPos) then
		pos[2] = Constants.roofPos
		self.yVel = 0
	end

	-- ground check
	if (pos[2] < Constants.floorPos) then
		pos[2] = Constants.floorPos
	end

	local screenSize = Vector.New(GetScreenSize())
	local PLAYER_MIN_XPOS = GetVehicleRestPosition()
	pos[1] = pos[1] + ((PLAYER_MIN_XPOS - pos[1]) * dt)
	SetPlayerPosition(pos[1], pos[2])
end

---
-- UpdateStateNone
--  Called when the current state is None
---
function HoverBoard:UpdateStateNone(dt)
	--Debug.Log(Debug.States, "HoverBoard:UpdateStateNone")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Hover:SetActive(false)

	self:SetState(HoverBoardState.Falling)
end

---
-- UpdateStateDead
--  Called when the current state is Dead
---
function HoverBoard:UpdateStateDead(dt)
	--Debug.Log(Debug.States, "HoverBoard:UpdateStateDead")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Hover:SetActive(false)
	self.Particles.Kickflip:SetActive(false)
end

---
-- UpdateStateGrounded
--  Called when the current state is Grounded
---
function HoverBoard:UpdateStateGrounded(dt)
	--Debug.Log(Debug.States, "HoverBoard:UpdateStateGrounded")
	self.Particles.Sparks:SetActive(true)
	self.Particles.Hover:SetActive(false)
	self.Particles.Kickflip:SetActive(false)

	self:SetState(HoverBoardState.Hovering)
end

---
-- UpdateStateHovering
--  Called when the current state is Hovering
---
function HoverBoard:UpdateStateHovering(dt)
	--Debug.Log(Debug.States, "HoverBoard:UpdateStateHovering")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Hover:SetActive(true)
	self.Particles.Kickflip:SetActive(false)

	-- ground
	local position = Vector.New(GetPlayerPosition())
	if (position[2] <= Constants.floorPos) then
		self:SetState(HoverBoardState.Grounded)
	end
end

---
-- UpdateStateJumping
--  Called when the current state is Jumping
---
function HoverBoard:UpdateStateJumping(dt)
	--Debug.Log(Debug.States, "HoverBoard:UpdateStateJumping")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Hover:SetActive(false)
	if (self.hasDoubleJumped) then
		self.Particles.Kickflip:SetActive(true)
	end

	-- change to falling
	if (self.yVel <= -100.0) then
		self:SetState(HoverBoardState.Falling)

		PlayAnimation(self.mTexture, "fall")
	end
end

---
-- UpdateStateFalling
--  Called when the current state is Falling
---
function HoverBoard:UpdateStateFalling(dt)
	--Debug.Log(Debug.States, "HoverBoard:UpdateStateFalling")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Hover:SetActive(false)
	self.Particles.Kickflip:SetActive(false)

	-- change to hover
	local position = Vector.New(GetPlayerPosition())
	if (position[2] < Constants.hoverPos) then
		self:SetState(HoverBoardState.Hovering)

		self.hasDoubleJumped = false
		self.isTouchingFloor = true

		PlayAnimation(self.texture, "skate")
		self.Sounds.Land:Play()
		self.Sounds.Engine:Play()
	end
end

function HoverBoard:Jump()
	--Debug.Log(Debug.General, "HoverBoard:Jump")
	self:SetState(HoverBoardState.Jumping)

	self.yVel = Constants.JumpVelStart
	self.isTouchingFloor = false
	self.jumpHeldTimer = 0.0

	PlayAnimation(self.texture, "ollie")

	local random = math.random(3)
	Log("HoverBoard: JumpSound:"..tostring(random))
	if (random == 1) then
		self.Sounds.Jump1:Play()
	elseif (random == 2) then
		self.Sounds.Jump2:Play()
	else
		self.Sounds.Jump3:Play()
	end
	self.Sounds.Engine:Stop(0.05)
end

function HoverBoard:DoubleJump()
	--Debug.Log(Debug.General, "HoverBoard:DoubleJump")
	self:SetState(HoverBoardState.Jumping)

	self.yVel = Constants.DoubleJumpVel
	self.hasDoubleJumped = true

	PlayAnimation(self.texture, "kickflip")
	self.Sounds.Kickflip:Play()
end

---
-- OnDraw
--  Called from cpp
--  Draws all the things.
---
function HoverBoard:OnDraw()
	local pos = Vector.New(GetPlayerPosition())
	DrawTexture(self.texture, pos[1], pos[2])
end

---
-- GetShadowWidth
--  Returns the width of the drop shadow.
---
function HoverBoard:GetShadowWidth()
	return 40.0
end

---
-- GetPlayerRectangle(<coin>)
--  Returns the player's bounds. (right, bottom, left, top)
--
-- Note: forCoin does not seem to be "for coins".
--       It looks like it's for destructible level objects and lights. meh.
---
function HoverBoard:GetPlayerRectangle(forCoin)
	local pos = Vector.New(GetPlayerPosition())
	return pos[1] + 15, pos[2] - 14, pos[1] - 15, pos[2] + 9 -- right, bottom, left, top
end

---
-- GetCollisionRectangle()
--  Returns the player's collision bounds (x, y, width, height)
---
function HoverBoard.GetCollisionRectangle()
	local pos = Vector.New(GetPlayerPosition())
	return pos[1], pos[2], 11, 6 -- x pos, y pos, x extent, y extent
end

---
-- GetRenderOffset()
---
function HoverBoard:GetRenderOffset()
	return 0, 0
end

---
-- GetConstructionRenderFlags()
---
function HoverBoard:GetConstructionRenderFlags()
	return 2
end

---
-- TouchUp()
--  Called from cpp, when Touch is Up
---
function HoverBoard:TouchUp()
	self.isTouchHeld = false
end

---
-- TouchDown()
--  Called from cpp, when Touch is Down
---
function HoverBoard:TouchDown()
	self.isTouchHeld = true

	if(self.isTouchingFloor)then
		self:Jump()
	elseif (self.hasDoubleJumped == false)then
		self:DoubleJump()
	end
end

---
-- Explode()
--  Called from cpp, when the Vehicle should blow up.
---
function HoverBoard:Explode()
	--Debug.Log(Debug.General, "HoverBoard:Explode")
	self.Sounds.Engine:Stop(0.05)
	self.Sounds.Death:Play()

	--Debug.Log(Debug.General, "HoverBoard:OnDestroy")
	self:StopAllSounds()
	self:DisableAllParticles()
end

---
-- OnDestroy()
--  Called from cpp, when the Vehicle has been destroyed.
---
function HoverBoard:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)

	self:StopAllSounds()
	self:DisableAllParticles()
end

function HoverBoard:OnCollision(actor)
	--Debug.Log(Debug.General, "HoverBoard:OnCollision")
	--self.yVel = self.yVel + 200.0
	return true
end

RegisterVehicle("HoverBoard", "ScriptVehicle", HoverBoard)
