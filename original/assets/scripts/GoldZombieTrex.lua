Log("GoldZombieTrex Lua script started")

GoldZombieTrex = {}
local rocketFlame
local headPos = 0
rocketTimer = 0.0
local running = false
local lastAnimationFrame = 0
local runDustLeft
local runDustRight
local jumpDust
local landDust
local leftCounter = 0.0
local leftMove = 0.0
local rightMove = 0.0
local rightCounter = 0.0
local moveJump = 0.0
local moveLand = 0.0
local jumpCounter = 0.0
local landCounter = 0.0
local flutterSound = -1
local playFlutter = -1

local goldSparkles

local function PlayRandomSfx(sfxList, loop)
	if (#sfxList > 0) then
		local s = math.random(#sfxList)
		loop = loop or false
		return SFX.PlaySound(sfxList[s], loop)
	end

	return -1
end

function GoldZombieTrex:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

function GoldZombieTrex:ComponentComplete()
	PlayRandomSfx(self.componentCompleteSfx)
end

function GoldZombieTrex:ConstructionComplete()
	PlayRandomSfx(self.constructionCompleteSfx)
	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

function GoldZombieTrex:GetSkinVectorAttributeOrDefault(name, x, y)
	local tx, ty = self:GetSkinVectorAttribute(name)
	if (tx == nil) then
		tx = x
	end
	if (ty == nil) then
		ty = y
	end

	return Vector.New(tx, ty)
end

function GoldZombieTrex:InitSkin()
	self.componentCompleteSfx = self:GetSkinArrayAttribute("componentCompleteSfx") 
		or { "trex_form_1", "trex_form_2", "trex_form_3" }

	self.leftStepSfx = self:GetSkinArrayAttribute("leftStepSfx") or { "trex_step_1" }
	self.leftStepAnimationFrame = self:GetSkinNumberAttribute("leftStepFrame") or 8

	self.rightStepSfx = self:GetSkinArrayAttribute("rightStepSfx") or { "trex_step_2" }
	self.rightStepAnimationFrame = self:GetSkinNumberAttribute("rightStepFrame") or 1

	self.roarSfx = self:GetSkinArrayAttribute("roarSfx")
	self.roarProbability = self:GetSkinNumberAttribute("roarProbability") or 0

	self.runDustAnimation = self:GetSkinAttribute("runDustAnimation") or "run"

	self.constructionCompleteSfx = self:GetSkinArrayAttribute("constructionCompleteSfx") or { "trex_form_complete" }
	self.flameOffSfx = self:GetSkinArrayAttribute("flameOffSfx")
	self.hitGroundSfx = self:GetSkinArrayAttribute("hitGroundSfx") or { "trex_land" }

	self.jumpSfx = self:GetSkinArrayAttribute("jumpSfx") or { "trex_jump" }
	self.flutterLpSfx = self:GetSkinArrayAttribute("flutterLpSfx") or { "trex_flutter_lp" }
	self.explodeSfx = self:GetSkinArrayAttribute("explodeSfx") or { "trex_death" }

	self.mechEffects = self:GetSkinBoolAttributeOrDefault("mechEffects", true)
	self.flameOffset = self:GetSkinVectorAttributeOrDefault("flameOffset", 2, -16)
end

function GoldZombieTrex:OnInit(info)
	self.Base.OnInit(self, info)

	self:InitSkin()

	OverloadVehicleSounds()
	OverloadPickupSounds()
	SetDrawBody(true)
	SetMechEffects(self.mechEffects)
	OverloadAllowHalo(true)
	SetMechFlameOffset(self.flameOffset[1], self.flameOffset[2])
	
	runDustLeft = LoadTexture("textures/Effects/runDust.xml", 9)
	runDustRight = LoadTexture("textures/Effects/runDust.xml", 9)
	jumpDust = LoadTexture("textures/Effects/jumpDust.xml", 9)
	landDust = LoadTexture("textures/Effects/landDust.xml", 9)

	playFlutter = -1
	--set a huge piece number so his body doesn't disappear
	SetConstructionBodyDisappearPieceNumber(99);

	goldSparkles = CreateParticle("GoldSparkle_Mech")
	SetParticleEnabled(goldSparkles, false)
end

function GoldZombieTrex.PickupSequenceUpdate(dt)
end

function GoldZombieTrex:Ready(skipPickupSeq)
	Log("Ready")

	VehicleUtils.PlaySong(self, "music", "ready")
	SetParticleEnabled(goldSparkles, true)
end

function GoldZombieTrex:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	if(running == true)then
		anim, animationFrame = GetAnimationFrame(-1)
		if (animationFrame == self.leftStepAnimationFrame 
				and lastAnimationFrame ~= self.leftStepAnimationFrame) then
			self:PlayStepSound(true)
			PlayAnimation(runDustLeft, self.runDustAnimation)
			Level.ScreenShake(0.2,0.2)
			leftCounter = 0.4
			leftMove = 0.0
		elseif(animationFrame == self.rightStepAnimationFrame 
				and lastAnimationFrame ~= self.rightStepAnimationFrame) then
			self:PlayStepSound(false)
			Level.ScreenShake(0.2,0.2)
			self:TrexRoar()
			PlayAnimation(runDustRight, self.runDustAnimation)
			rightCounter = 0.4
			rightMove = 0.0
		end
	end
	anim, lastAnimationFrame = GetAnimationFrame(-1)

	if(leftCounter > 0.0)then
		leftCounter = leftCounter - dt
		leftMove = leftMove + 2
		--Log("LeftMove "..leftMove)
	end
	if(leftCounter < 0.0)then
		leftCounter = 0.0
	end
	if(rightCounter > 0.0)then
		rightCounter = rightCounter - dt
		rightMove = rightMove + 2
		--Log("RightMove "..rightMove)
	end
	if(rightCounter < 0.0)then
		rightCounter = 0.0
	end

	if(jumpCounter > 0.0)then
		jumpCounter = jumpCounter - dt
		moveJump = moveJump + 2
	end
	if(jumpCounter < 0.0)then
		jumpCounter = 0.0
		moveJump = 0.0
	end

	if(landCounter > 0.0)then
		landCounter = landCounter - dt
		moveLand = moveLand + 2
	end
	if(landCounter < 0.0)then
		landCounter = 0.0
		moveLand = 0.0
	end

end

function GoldZombieTrex:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	anim, runDustLeftFrame = GetAnimationFrame(runDustLeft)
	anim, runDustRightFrame = GetAnimationFrame(runDustRight)
	anim, jumpDustFrame = GetAnimationFrame(jumpDust)
	anim, landDustFrame = GetAnimationFrame(landDust)

	if(runDustLeftFrame < 11)then
		DrawTexture(runDustLeft, (headPos[1] + 10 - leftMove), -110)
	end
	if(runDustRightFrame < 11)then
		DrawTexture(runDustRight, (headPos[1] - rightMove), -115)
	end
	if(jumpDustFrame < 5)then
		DrawTexture(jumpDust, (headPos[1] - moveJump), -70)
	end
	if(landDustFrame < 3)then
		DrawTexture(landDust, (headPos[1] - moveLand), -135)
	end

	sparklesPos = headPos + Vector.New(5.0, -4.0)
	worldPos = Vector.New(Level.GetOffset())
	finalSparklesPos = sparklesPos - worldPos		

	SetParticlePosition(goldSparkles, finalSparklesPos[1] - 7, finalSparklesPos[2])
end

function GoldZombieTrex:HitGround()
	Log("HitGround")
	PlayRandomSfx(self.hitGroundSfx)
	PlayAnimation(landDust, "land")
	Level.ScreenShake(0.2,5)
	landCounter = 0.4
	if(playFlutter == 1)then
		SFX.StopSound(flutterSound or -1)
		playFlutter = -1
	end
	running = true
end

function GoldZombieTrex:OnJump()
	running = false
	PlayRandomSfx(self.jumpSfx)
	PlayAnimation(jumpDust, "jump")
	jumpCounter = 0.4
	Log("Jump!")
end

function GoldZombieTrex.TouchUp()
	inputUp = true
end

function GoldZombieTrex.TouchDown()
	inputUp = false
end

function GoldZombieTrex:PlayStepSound(left)
	if (left) then
		PlayRandomSfx(self.leftStepSfx)
	else
		PlayRandomSfx(self.rightStepSfx)
	end
end

function GoldZombieTrex:StartBoost()
	self:TrexRoar()
	if (playFlutter == -1) then
		flutterSound = PlayRandomSfx(self.flutterLpSfx, true)
		playFlutter = 1
	end
end

function GoldZombieTrex:StopBoost()
	if(playFlutter == 1)then
		SFX.StopSound(flutterSound or -1)
		playFlutter = -1
	end
end

function GoldZombieTrex:FlameOn()
	Log("FlameOn")
end

function GoldZombieTrex:FlameOff()
	Log("FlameOff")
	PlayRandomSfx(self.flameOffSfx)
end

function GoldZombieTrex:Explode()
	Log("Explode")
	if(playFlutter == 1)then
		Log("Stop Sound!!")
		SFX.StopSound(flutterSound or -1,0.1)
		playFlutter = -1
	end

	PlayRandomSfx(self.explodeSfx)
end

function GoldZombieTrex:OnDestroy()
	local outroPlayed = VehicleUtils.PlayOutro(self)
	local clearSongOverride = not outroPlayed
	self.Base.OnDestroy(self, clearSongOverride)
end

function GoldZombieTrex:TrexRoar()
	local r = math.random(100)
	if (r < self.roarProbability) then
		PlayRandomSfx(self.roarSfx)
	end
end

function GoldZombieTrex.FlashToAnim_land()

end

function GoldZombieTrex.FlashToAnim_run()

end

function GoldZombieTrex.FlashToAnim_jumpLaunch()

end

RegisterVehicle("GoldZombieTrex", "Mech", GoldZombieTrex);
