Log("IceSkates Lua script started v1.0.0")

local Constants =
{
	JumpVelStart = 330.0,
	JumpVelEnd = 370.0,
	JumpHeldMax = 0.2,
	DoubleJumpVel = 310.0,

	accelDown = -1050.0,
	maxDown = -830.0,

	roofPos =  116,
	floorPos = -118,
	fallHeight = -50
}

---
-- enum IceSkatesState
---
local IceSkatesState =
{
	None = -1,
	Dead = 0,
	Grounded = 1,
	Jumping = 2,
	Falling = 3,
}


-- The IceSkates itself
IceSkates = IceSkates or {}

IceSkates.rotation = 0.0
IceSkates.isTouchHeld = false
IceSkates.hasDoubleJumped = false
IceSkates.isTouchingFloor = false
IceSkates.yVel = 0.0
IceSkates.jumpHeldTimer = 0.0
IceSkates.texture = nil
IceSkates.lastAnimationFrame = nil
IceSkates.State = {}
IceSkates.State.previous = IceSkatesState.None
IceSkates.State.current = IceSkatesState.None

IceSkates.Particles = {}
IceSkates.Particles.Sparks = Particle.new("IceSkates_Sparks", Vector.New(5, -10), ParticleLTWType.LevelRelative)
IceSkates.Particles.Sliding = Particle.new("IceSkates_Sliding", Vector.New(0, -20), ParticleLTWType.LevelRelative)
IceSkates.Particles.Kickflip = Particle.new("IceSkates_Spin", Vector.New(0, 0), ParticleLTWType.LevelRelative)

IceSkates.Sounds = {}

-- Jump sounds
IceSkates.Sounds.Jump = {
    Sound.new("iceskates_jump_1"), 
    Sound.new("iceskates_jump_2"), 
    Sound.new("iceskates_jump_3")
}

-- Jump spin sounds
IceSkates.Sounds.JumpSpin = {
    Sound.new("iceskates_jumpspin_1"),
    Sound.new("iceskates_jumpspin_2"),
    Sound.new("iceskates_jumpspin_3")
}

-- Landing from regular jump sounds
IceSkates.Sounds.Land = {
    Sound.new("iceskates_land_1"),
    Sound.new("iceskates_land_2"),
    Sound.new("iceskates_land_3")
}

-- Landing from double jump sounds
IceSkates.Sounds.JumpSpinLand = {
    Sound.new("iceskates_jumpspin_land_1"),
    Sound.new("iceskates_jumpspin_land_2"),
    Sound.new("iceskates_jumpspin_land_3")
}

-- Skiing left sounds
IceSkates.Sounds.StepLeft = {
    Sound.new("iceskates_step_left_1"),
    Sound.new("iceskates_step_left_2"),
    Sound.new("iceskates_step_left_3"),
    Sound.new("iceskates_step_left_4")
}

-- Skiing right sounds
IceSkates.Sounds.StepRight = {
    Sound.new("iceskates_step_right_1"),
    Sound.new("iceskates_step_right_2"),
    Sound.new("iceskates_step_right_3"),
    Sound.new("iceskates_step_right_4")
}
---
-- DisableAllParticles()
--  Does what it says.
---
function IceSkates:DisableAllParticles()
	self.Particles.Sparks:SetActive(false)
	self.Particles.Sliding:SetActive(false)
end

---
-- StopAllSounds()
-- Does what it says.
---
function IceSkates:StopAllSounds()
	VehicleUtils.StopAllSFX(self.Sounds.Jump) 
	VehicleUtils.StopAllSFX(self.Sounds.JumpSpin)
	VehicleUtils.StopAllSFX(self.Sounds.Land)
	VehicleUtils.StopAllSFX(self.Sounds.JumpSpinLand)
end
---
-- SetState
--  Called when ever you want to change the current IceSkatesState
---
function IceSkates:SetState(state)
	self.State.previous = IceSkates.State.current
	self.State.current = state
end

function IceSkates.GetTextureList()
	return
	"textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component1.tex"..
	"|textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component2.tex"..
	"|textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component3.tex"..
	"|textures/Characters/Vehicles/Components/HoverBoard/HoverBoard/component4.tex"
end

function IceSkates:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

---
-- PickupStart()
--  ???
---
function IceSkates:PickupStart()
	--Debug.Log(Debug.General, "IceSkates:PickupStart")
	OffsetPickupComponents(-16,9)
end

---
-- ComponentComplete
--  Called from cpp during construction, when one of the components has snapped in place.
---
function IceSkates:ComponentComplete()
	--Debug.Log(Debug.General, "IceSkates:ComponentComplete")
end

---
-- ConstructionComplete()
--  Called from cpp, when the IceSkates has finished being constructed.
---
function IceSkates:ConstructionComplete()
	--Debug.Log(Debug.General, "IceSkates:ConstructionComplete")
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
function IceSkates:OnInit(info)
	--Debug.Log(Debug.General, "IceSkates:OnInit")
	self.Base.OnInit(self, info)

	pos = Vector.New(GetPlayerPosition())

	self.hasDoubleJumped = false
	self.isTouchingFloor = true
	if(pos[2] > Constants.floorPos)then
		self.isTouchingFloor = false
	end

	self.yVel = 0

	self.texture = LoadTexture("textures/Characters/Vehicles/IceSkates/IceSkates/iceskates.xml", 10)
	if(self.isTouchingFloor == true)then
		self:SetState(IceSkatesState.Grounded)
		PlayAnimation(self.texture, "skate")
	else
		self:SetState(IceSkatesState.Falling)
		PlayAnimation(self.texture, "fall")
	end

	SetVehicleScreenShotRating(50)
	self:SetDrawHead(false)
end

---
-- PickupSequenceUpdate()
--  ???
---
function IceSkates:PickupSequenceUpdate(dt)
	--Debug.Log(Debug.General, "IceSkates:PickupSequenceUpdate")
end

---
-- Ready()
--  ???
---
function IceSkates:Ready(skipPickupSeq)
	--Debug.Log(Debug.General, "IceSkates:Ready")
	VehicleUtils.PlaySong(self, "music", "ready")
end

---
-- OnUpdate(dt)
--  Called from cpp, once per frame.
---
function IceSkates:OnUpdate(dt)

	if (self.State.current == IceSkatesState.None) then
		self:UpdateStateNone(dt)
	elseif (self.State.current == IceSkatesState.Grounded) then
		self:UpdateStateGrounded(dt)
	elseif (self.State.current == IceSkatesState.Jumping) then
		self:UpdateStateJumping(dt)
	elseif (self.State.current == IceSkatesState.Falling) then
		self:UpdateStateFalling(dt)
	else
		self:UpdateStateDead(dt)
	end

	self:UpdatePosition(dt)

	self.Particles.Sparks:Update(self)
	self.Particles.Sliding:Update(self)
	self.Particles.Kickflip:Update(self)

	-- updates the magnet particles
	UpdateVehicleParticles()

	--Update stepping sound
	self:UpdateVehicleStepSound()

	VehicleUpdateSpeed(dt)

end

---
-- UpdatePosition
--  This handles the movement of the IceSkates whether it is hovering, jumping, falling..etc
---
function IceSkates:UpdatePosition(dt)
	local pos = Vector.New(GetPlayerPosition())

	-- gravity
	self.yVel = self.yVel + (Constants.accelDown * dt)

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
-- UpdateVehicleStepSound
--  Handles stepping sound for this vehicle
---
function IceSkates:UpdateVehicleStepSound()
	if (self.isTouchingFloor == true) then
		local anim, animationFrame = GetAnimationFrame(self.texture)

		if (animationFrame == 1 and self.lastAnimationFrame ~= 1) then
			VehicleUtils.PlayRandomSFX(self.Sounds.StepLeft)
		elseif (animationFrame == 3 and self.lastAnimationFrame ~= 3) then
			VehicleUtils.PlayRandomSFX(self.Sounds.StepRight)
		end
		self.lastAnimationFrame = animationFrame
	end
end

---
-- UpdateStateNone
--  Called when the current state is None
---
function IceSkates:UpdateStateNone(dt)
	--Debug.Log(Debug.States, "IceSkates:UpdateStateNone")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Sliding:SetActive(false)

	self:SetState(IceSkatesState.Falling)
end

---
-- UpdateStateDead
--  Called when the current state is Dead
---
function IceSkates:UpdateStateDead(dt)
	--Debug.Log(Debug.States, "IceSkates:UpdateStateDead")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Sliding:SetActive(false)
	self.Particles.Kickflip:SetActive(false)
end

---
-- UpdateStateGrounded
--  Called when the current state is Grounded
---
function IceSkates:UpdateStateGrounded(dt)
	--Debug.Log(Debug.States, "IceSkates:UpdateStateGrounded")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Sliding:SetActive(true)
	self.Particles.Kickflip:SetActive(false)
end

---
-- UpdateStateJumping
--  Called when the current state is Jumping
---
function IceSkates:UpdateStateJumping(dt)
	--Debug.Log(Debug.States, "IceSkates:UpdateStateJumping")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Sliding:SetActive(false)
	if (self.hasDoubleJumped) then
		self.Particles.Kickflip:SetActive(true)
	end

	-- change to falling
	if (self.yVel <= -100.0) then
		self:SetState(IceSkatesState.Falling)
	end
end

---
-- UpdateStateFalling
--  Called when the current state is Falling
---
function IceSkates:UpdateStateFalling(dt)
	--Debug.Log(Debug.States, "IceSkates:UpdateStateFalling")
	self.Particles.Sparks:SetActive(false)
	self.Particles.Sliding:SetActive(false)
	self.Particles.Kickflip:SetActive(false)

	if not IsAnimating_(self.texture) then
		local anim, frame = GetAnimationFrame(self.texture)
		if anim ~= "fall" then
			PlayAnimation(self.texture, "fall")
		end
	end

	-- change to skiing
	local position = Vector.New(GetPlayerPosition())
	if (position[2] <= Constants.floorPos) then
		self:SetState(IceSkatesState.Grounded)

		PlayAnimation(self.texture, "skate")

		if self.hasDoubleJumped then
			VehicleUtils.PlayRandomSFX(self.Sounds.JumpSpinLand)
		else
			VehicleUtils.PlayRandomSFX(self.Sounds.Land)
		end

		self.Particles.Sparks:SetActive(true)
		self.hasDoubleJumped = false
		self.isTouchingFloor = true
	end

end

function IceSkates:Jump()
	--Debug.Log(Debug.General, "IceSkates:Jump")
	self:SetState(IceSkatesState.Jumping)

	self.yVel = Constants.JumpVelStart
	self.isTouchingFloor = false
	self.jumpHeldTimer = 0.0

	PlayAnimation(self.texture, "ollie")
	
	VehicleUtils.PlayRandomSFX(self.Sounds.Jump)
end

function IceSkates:DoubleJump()
	--Debug.Log(Debug.General, "IceSkates:DoubleJump")
	self:SetState(IceSkatesState.Jumping)

	self.yVel = self.yVel + Constants.DoubleJumpVel;

	self.hasDoubleJumped = true

	PlayAnimation(self.texture, "kickflip")

	VehicleUtils.PlayRandomSFX(self.Sounds.JumpSpin)
end

---
-- OnDraw
--  Called from cpp
--  Draws all the things.
---
function IceSkates:OnDraw()
	local pos = Vector.New(GetPlayerPosition())
	DrawTexture(self.texture, pos[1], pos[2])
end

---
-- GetShadowWidth
--  Returns the width of the drop shadow.
---
function IceSkates:GetShadowWidth()
	return 40.0
end

---
-- GetPlayerRectangle(<coin>)
--  Returns the player's bounds. (right, bottom, left, top)
--
-- Note: forCoin does not seem to be "for coins".
--       It looks like it's for destructible level objects and lights. meh.
---
function IceSkates:GetPlayerRectangle(forCoin)
	local pos = Vector.New(GetPlayerPosition())
	return pos[1] + 15, pos[2] - 14, pos[1] - 15, pos[2] + 9 -- right, bottom, left, top
end

---
-- GetCollisionRectangle()
--  Returns the player's collision bounds (x, y, width, height)
---
function IceSkates.GetCollisionRectangle()
	local pos = Vector.New(GetPlayerPosition())
	return pos[1], pos[2], 11, 6 -- x pos, y pos, x extent, y extent
end

---
-- GetRenderOffset()
---
function IceSkates:GetRenderOffset()
	return 0, 0
end

---
-- GetConstructionRenderFlags()
---
function IceSkates:GetConstructionRenderFlags()
	return 2
end

---
-- TouchUp()
--  Called from cpp, when Touch is Up
---
function IceSkates:TouchUp()
	self.isTouchHeld = false
end

---
-- TouchDown()
--  Called from cpp, when Touch is Down
---
function IceSkates:TouchDown()
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
function IceSkates:Explode()
	--Debug.Log(Debug.General, "IceSkates:Explode")
	--Debug.Log(Debug.General, "IceSkates:OnDestroy")
	self:StopAllSounds()
	self:DisableAllParticles()
end

---
-- OnDestroy()
--  Called from cpp, when the Vehicle has been destroyed.
---
function IceSkates:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)

	self:StopAllSounds()
	self:DisableAllParticles()
end

function IceSkates:OnCollision(actor)
	--Debug.Log(Debug.General, "IceSkates:OnCollision")
	--self.yVel = self.yVel + 200.0
	return true
end

RegisterVehicle("IceSkates", "ScriptVehicle", IceSkates)
