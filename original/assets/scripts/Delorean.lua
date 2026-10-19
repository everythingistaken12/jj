Log("Delorean Lua script started v1.2.36")

---
-- Constants
---
local Constants =
{
	SpeedingUp =
	{
		startSpeed = 38,
		targetSpeed = 88,

		-- The level speed multipler, multiplied with Constants.horizontalSpeedMultiplier
		speedMultiplier = 1.0,

		-- <shakeName>, <triggerAtSpeed>, <shakeTime>, <shakeIntensity>, <shakeSpeed>
		HudShakes =
		{
			HudShake.New( "HudShake1",  5.00, 0.75, 1.0 ),
			HudShake.New( "HudShake2",  5.00, 1.50, 1.5 ),
			HudShake.New( "HudShake3",  5.00, 1.75, 2.5 ),
		}
	},

	Hit88Begin =
	{
		-- The level speed multipler, multiplied with Constants.horizontalSpeedMultiplier
		speedMultiplier = 1.3,
	},

	Hit88Middle =
	{
		-- The level speed multipler, multiplied with Constants.horizontalSpeedMultiplier
		speedMultiplier = 1.6,
	},

	Hit88End =
	{
		-- The level speed multipler, multiplied with Constants.horizontalSpeedMultiplier
		speedMultiplier = 2.2,
	},

	Disappeared =
	{
		-- <shakeName>, <triggerAtSpeed>, <shakeTime>, <shakeIntensity>, <shakeSpeed>
		hudShake = HudShake.New( "Disappeared", 1.15, 20.0, 5.5 ),

		FastForward =
		{
			speed = 1100,
			rampUpTime = 0.4,
			rampDownTime = 0.75,
		},
	},

	ReappearBegin =
	{
		-- <shakeName>, <triggerAtSpeed>, <shakeTime>, <shakeIntensity>, <shakeSpeed>
		hudShake = HudShake.New( "ReappearBegin", 0.5, 0.5, 3.5 ),
	},

	ReappearMiddle =
	{
		-- The level speed multipler, multiplied with Constants.horizontalSpeedMultiplier
		speedMultiplier = 2.6,

		-- <shakeName>, <triggerAtSpeed>, <shakeTime>, <shakeIntensity>, <shakeSpeed>
		hudShake = HudShake.New( "ReappearMiddle", 0.5, 3.0, 3.5 ),
	},

	ReappearEnd =
	{
		-- <shakeName>, <triggerAtSpeed>, <shakeTime>, <shakeIntensity>, <shakeSpeed>
		hudShake = HudShake.New( "ReappearEnd", 0.5, 6.0, 3.5 ),
	},

	accelUp = 1550.0,
	accelDown = -550.0,
	maxUp = 220.0,
	maxDown = -220.0,

	-- The tire fire will lerp across the screen for this amount of time
	tyreFireTime = 0.97,

	-- The car has just disappeared, this is how long we shall hesitate before doing the level speed boost
	disappearedStunTime = 1.7,

	-- We've just done a level speed boost, and the car is still disappeared, remain stunned for this time before reappearing
	reappearStunTime = 1.1,

	-- We've reappeared and played the Reappear stun sound, now start engine after this time
	reappearStartEngineTime = 1.0,

	reappearStartSpeed = 400.0,

	-- The MPH-to-LevelMeters scalar
	horizontalSpeedMultiplier = 7.0,

	GlowToDisappear =
	{
		fadeIn = { time=0.45, alpha=1.0 },
		fadeOut = { time=0.0, alpha=0.0 },
		posTween = nil,
	},
	FlashGlow1=
	{
		fadeIn = { time=0.01, alpha=0.9 },
		fadeOut = { time=0.2, alpha=0.0 },
		posTween = { source=Vector.New(-185, 0), dest=Vector.New(250, 0) },
	},
	FlashGlowAppear =
	{
		fadeIn = { time=0.0, alpha=1.0 },
		fadeOut = { time=5.0, alpha=0.0 },
		posTween = nil,
	},
}

---
-- SpeedingUp Events
---
local SpeedEvent1 = SpeedEvent.New( "SpeedEvent1", 40 )
local SpeedEvent2 = SpeedEvent.New( "SpeedEvent2", 50 )
local SpeedEvent3 = SpeedEvent.New( "SpeedEvent3", 60 )
local SpeedEvent4 = SpeedEvent.New( "SpeedEvent4", 70 )
local SpeedEvent5 = SpeedEvent.New( "SpeedEvent5", 84 )

---
-- enum DeloreanState
---
local DeloreanState =
{
	None = 0,

	Spawned = 1,
	SpeedingUp = 2,

	Hit88Begin = 3,
	Hit88Middle = 4,
	Hit88End = 5,

	Disappeared = 6,

	ReappearBegin = 7,
	ReappearMiddle = 8,
	ReappearEnd = 9,

	Dead = -1,
}

---
-- The DeloreanState's Max times
---
DeloreanState.MaxTimes = {}
DeloreanState.MaxTimes[DeloreanState.None          ] = 0.25
DeloreanState.MaxTimes[DeloreanState.Spawned       ] = 0.25
DeloreanState.MaxTimes[DeloreanState.SpeedingUp    ] = 7.50
DeloreanState.MaxTimes[DeloreanState.Hit88Begin    ] = 0.20
DeloreanState.MaxTimes[DeloreanState.Hit88Middle   ] = 0.40
DeloreanState.MaxTimes[DeloreanState.Hit88End      ] = 0.80
DeloreanState.MaxTimes[DeloreanState.Disappeared   ] = 2.30 + Constants.disappearedStunTime + Constants.reappearStunTime
DeloreanState.MaxTimes[DeloreanState.ReappearBegin ] = 0.40
DeloreanState.MaxTimes[DeloreanState.ReappearMiddle] = 0.40
DeloreanState.MaxTimes[DeloreanState.ReappearEnd   ] = -1.0
DeloreanState.MaxTimes[DeloreanState.Dead          ] = -1.0

---
-- The DeloreanState's Names
---
DeloreanState.Names = {}
DeloreanState.Names[DeloreanState.None          ] = "None"
DeloreanState.Names[DeloreanState.Spawned       ] = "Spawned"
DeloreanState.Names[DeloreanState.SpeedingUp    ] = "SpeedingUp"
DeloreanState.Names[DeloreanState.Hit88Begin    ] = "Hit88Begin"
DeloreanState.Names[DeloreanState.Hit88Middle   ] = "Hit88Middle"
DeloreanState.Names[DeloreanState.Hit88End      ] = "Hit88End"
DeloreanState.Names[DeloreanState.Disappeared   ] = "Disappeared"
DeloreanState.Names[DeloreanState.ReappearBegin ] = "ReappearBegin"
DeloreanState.Names[DeloreanState.ReappearMiddle] = "ReappearMiddle"
DeloreanState.Names[DeloreanState.ReappearEnd   ] = "ReappearEnd"
DeloreanState.Names[DeloreanState.Dead          ] = "Dead"

---
-- GlowSprite class, extends Sprite
---
local GlowSprite = {}
function GlowSprite.New(assetPath, drawLayer)
	local newGlowSprite = {}
	newGlowSprite.Base = Sprite.New(assetPath, drawLayer)

	newGlowSprite.FadeIn =
	{
		time = 0.5,
		alpha = 1.0,
	}
	newGlowSprite.FadeOut =
	{
		time = 1.0,
		alpha = 0.0,
	}
	newGlowSprite.posTween = nil
	newGlowSprite.animate = false
	newGlowSprite.time = 0.0
	newGlowSprite.basePos = Vector.New(0,0)
	newGlowSprite.adjustedPos = Vector.New(0,0)

	---
	-- Load function
	---
	function newGlowSprite:Load()
		self.Base:Load()
	end

	---
	-- PlayAnimation
	---
	function newGlowSprite:PlayAnimation(animName)
		self.Base:PlayAnimation(animName)
	end

	---
	-- Animate
	--  Takes a fadeIn and fadeOut
	--  Each is expected to have at least a { time, alpha } field pair.
	---
	function newGlowSprite:Animate(fadeIn, fadeOut, posTween)
		-- FadeIn
		self.FadeIn.time  = fadeIn.time
		self.FadeIn.alpha = fadeIn.alpha

		-- FadeOut
		self.FadeOut.time  = fadeOut.time
		self.FadeOut.alpha = fadeOut.alpha

		-- Positional Tweening
		if (posTween ~= nil) then
			self.PosTween = {}
			self.PosTween.source = posTween.source
			self.PosTween.dest = posTween.dest
		else
			self.PosTween = nil
		end

		self.basePos = Vector.New(0,0)
		self.adjustedPos = Vector.New(0,0)

		self.animate = true
		self.Base.tweenAlpha = false

		self:SetVisible(true)
		self:ResetTime()
	end

	---
	-- ResetTime
	---
	function newGlowSprite:ResetTime()
		self.Base:ResetTime()
		self.time = 0.0
	end

	---
	-- Update Function
	---
	function newGlowSprite:Update(dt)
		if (self.animate and self.Base.isVisible) then
			self.time = self.time + dt

			local alpha = 0.0
			local fadeInTime = self.FadeIn.time
			local canFadeIn = fadeInTime > 0

			-- Clamp Fade In Time
			if (canFadeIn == false) then
				fadeInTime = 0.0
			end

			local fadeOutTime = self.FadeOut.time
			local canFadeOut = fadeOutTime > 0

			-- Clamp Fade Out Time
			if (canFadeOut == false) then
				fadeOutTime = 0.0
			end

			if (canFadeIn and fadeInTime > self.time) then

				-- Fade In
				local time = self.time
				local fadeTime = fadeInTime
				local fadeAlphaFrom = 0.0
				local fadeAlphaTo = self.FadeIn.alpha

				-- Fading in
				local fadeDelta = time / fadeTime

				alpha = Lerp.Linear.Tween(fadeAlphaFrom, fadeAlphaTo, fadeDelta)
			elseif (canFadeOut and fadeOutTime > (self.time - fadeInTime)) then

				-- Fade Out
				local time = self.time - fadeInTime
				local fadeTime = fadeOutTime
				local fadeAlphaFrom = self.FadeIn.alpha
				local fadeAlphaTo = self.FadeOut.alpha

				-- Fading out
				local fadeDelta = time / fadeTime
				alpha = Lerp.Linear.Tween(fadeAlphaFrom, fadeAlphaTo, fadeDelta)
			else
				-- Full-fade
				alpha = self.FadeOut.alpha
				self.animate = false
			end

			self:SetAlpha(alpha)
		end

		-- Positional Tweening
		if (self.animate and self.Base.isVisible and self.PosTween ~= nil) then
			local fadeInTime = self.FadeIn.time
			local canFadeIn = fadeInTime > 0

			-- Clamp Fade In Time
			if (canFadeIn == false) then
				fadeInTime = 0.0
			end

			local fadeOutTime = self.FadeOut.time
			local canFadeOut = fadeOutTime > 0

			-- Clamp Fade Out Time
			if (canFadeOut == false) then
				fadeOutTime = 0.0
			end

			local maxTime = fadeInTime + fadeOutTime
			if (maxTime > 0) then
				local lerpDelta = self.time / maxTime
				lerpDelta = math.min(1.0, math.max(0.0, lerpDelta))

				self.adjustedPos = Vector.New(0,0)
				self.adjustedPos[1] = Lerp.Linear.Tween(self.PosTween.source[1], self.PosTween.dest[1], lerpDelta)
				self.adjustedPos[2] = Lerp.Linear.Tween(self.PosTween.source[2], self.PosTween.dest[2], lerpDelta)
			end
		end

		self.Base.pos = self.basePos + self.adjustedPos
		self.Base:Update(dt)
	end

	---
	-- Draw function
	---
	function newGlowSprite:Draw()
		self.Base:Draw()
	end

	---
	-- SetPos function
	---
	function newGlowSprite:SetPos(pos)
		self.basePos = Vector.Clone(pos)
		self.Base.pos = self.basePos + self.adjustedPos
	end

	---
	-- SetRotation function
	---
	function newGlowSprite:SetRotation(rotation)
		self.Base.rotation = rotation
	end

	---
	-- SetVisible function
	---
	function newGlowSprite:SetVisible(isVisible)
		self.Base.isVisible = isVisible
	end

	---
	-- SetAlpha function
	---
	function newGlowSprite:SetAlpha(alpha)
		self.Base.alpha = alpha
	end

	return newGlowSprite
end

-- The Delorean itself
Delorean = Delorean or {}

-- Delorean members
Delorean.rotation = 0.0
Delorean.verticalSpeed = 0.0
Delorean.verticalAcceleration = 0.0
Delorean.horizontalSpeed = 0.0
Delorean.startSpeed = 0.0
Delorean.targetSpeed = 0.0
Delorean.isPressed = false
Delorean.startJumpDist = 0
Delorean.jetFlameScale = Vector.New(1.0, 1.0)

---
-- The current Delorean's state
---
Delorean.State = {}
Delorean.State.current = DeloreanState.None
Delorean.State.updateCount = 0
Delorean.State.time = 0.0
Delorean.State.prevTime = 0.0
Delorean.State.maxTime = DeloreanState.MaxTimes[Delorean.State.current]

---
-- Delorean Particles
---
Delorean.Particles = {}
Delorean.Particles.FireTyre                = Particle.new("delorean_tyre_fire"        , Vector.New(0, -30)     , ParticleLTWType.LevelRelative  , true)
Delorean.Particles.TimeTravelStreaks2      = Particle.new("Time_Travel_Streaks2"      , Vector.New(0, 0)       , ParticleLTWType.Fullscreen     , true)
Delorean.Particles.TimeTravelStreaks1      = Particle.new("Time_Travel_Streaks1"      , Vector.New(0, 0)       , ParticleLTWType.Fullscreen     , true)
Delorean.Particles.DeloreanSparks          = Particle.new("Delorean_Sparks"           , Vector.New(90, -10)    , ParticleLTWType.ScreenRelative , true)
Delorean.Particles.DeloreanSparksBuildup   = Particle.new("Delorean_Sparks_Buildup"   , Vector.New(90, -10)    , ParticleLTWType.ScreenRelative , true)
Delorean.Particles.DustCloud               = Particle.new("Dust_explosion"            , Vector.New(90, -10)    , ParticleLTWType.LevelRelative  , false)
Delorean.Particles.DeloreanFlash1          = Particle.new("Delorean_Flash_Emitter1"   , Vector.New(50, -10)    , ParticleLTWType.LevelRelative  , false)
Delorean.Particles.DeloreanFlashEmitter2   = Particle.new("Delorean_Flash_Emitter2"   , Vector.New(30, -10)    , ParticleLTWType.LevelRelative  , false)
Delorean.Particles.DeloreanFlashEmitter3   = Particle.new("Delorean_Flash_Emitter3"   , Vector.New(30, -10)    , ParticleLTWType.LevelRelative  , false)
Delorean.Particles.DeloreanImplosion       = Particle.new("Delorean_Implosion"        , Vector.New(100, -10)   , ParticleLTWType.LevelRelative  , false)
Delorean.Particles.BlueDustCloud           = Particle.new("Blue_Dust_Cloud"           , Vector.New(30, -10)    , ParticleLTWType.LevelRelative  , false)
Delorean.Particles.DeloreanMiniNoseCone    = Particle.new("Delorean_Mini_Nose_Cone"   , Vector.New(110, -10)   , ParticleLTWType.LevelRelative  , true)
Delorean.Particles.DeloreanNoseCone        = Particle.new("Delorean_Nose_Cone"        , Vector.New(110, -10)   , ParticleLTWType.LevelRelative  , true)
Delorean.Particles.DeloreanShootingSparksLow = Particle.new("Delorean_ShootingSparks_Low" , Vector.New(-45, -8), ParticleLTWType.LevelRelative  , true)
Delorean.Particles.DeloreanShootingSparksHigh= Particle.new("Delorean_ShootingSparks_High", Vector.New(-45, -8), ParticleLTWType.LevelRelative  , true)
Delorean.Particles.DeloreanExhaust         = Particle.new("Delorean_Exhaust"          , Vector.New(-63, 10)    , ParticleLTWType.LevelRelative  , true)
Delorean.Particles.DeloreanExhaustBoost    = Particle.new("Delorean_Exhaust_Boost"   , Vector.New(-63, 10)     , ParticleLTWType.LevelRelative  , true)
Delorean.Particles.DeloreanFloorVent       = Particle.new("Delorean_Hover_Mist"      , Vector.New(0, -20)      , ParticleLTWType.ScreenRelative , true)
Delorean.Particles.DeloreanLightning       = Particle.new("Delorean_lightning"       , Vector.New(0, 20)       , ParticleLTWType.LevelRelative  , true)

---
-- Delorean Sounds
---
Delorean.Sounds = {}

-- to play when the vehicle has finished forming
Delorean.Sounds.FormComplete = Sound.new("delorean_form_complete")

-- looping sound to play while the Delorean is active. I think this should continue to play while it's in the air, but we'll have to see how it sounds
Delorean.Sounds.Engine   = Sound.new("delorean_engine_lp", true, 1.0)

-- looping sound to play when the player is holding on the screen to activate the rockets
Delorean.Sounds.Rockets  = Sound.new("delorean_rockets_lp", true, 1.0)

-- to play when the player releases to stop the rockets
Delorean.Sounds.RocketsStop = Sound.new("delorean_rockets_stop")

-- to play when the visual effect starts in the build-up to the time travel teleport
Delorean.Sounds.TimeBuild = Sound.new("delorean_time_build")

-- to play when the time teleport is activated
Delorean.Sounds.TimeEnter = Sound.new("delorean_time_enter")

-- to play when the time teleport finishes (when the player is teleported 500m further on)
Delorean.Sounds.TimeExit = Sound.new("delorean_time_exit")

-- to play when it is destroyed
Delorean.Sounds.Death = Sound.new("delorean_death")

-- to play when the tubes start glowing (I think this is at 50 mph)
Delorean.Sounds.Tubes    = Sound.new("delorean_tubes")

-- looping sound to start playing when the shaking/sparks/fire begin (I think this is at 80 mph?)
-- This sound needs to stop when delorean_time_enter triggers (i.e. when the time teleport begins)
Delorean.Sounds.BuildLP  = Sound.new("delorean_build_lp", true, 1.0)

-- to play in order for each blue flash before the re-entry
Delorean.Sounds.Flash1   = Sound.new("delorean_flash_1")
Delorean.Sounds.Flash2   = Sound.new("delorean_flash_2")
Delorean.Sounds.Flash3   = Sound.new("delorean_flash_3")

-- as discussed, these are to play sequentially for each increment of either 10 or 5 on the speedo HUD.
Delorean.Sounds.Beep1     = Sound.new("delorean_beep_1" , false, 1.0, SpeedEvent.New("Beep", 40))
Delorean.Sounds.Beep2     = Sound.new("delorean_beep_2" , false, 1.0, SpeedEvent.New("Beep", 45))
Delorean.Sounds.Beep3     = Sound.new("delorean_beep_3" , false, 1.0, SpeedEvent.New("Beep", 50))
Delorean.Sounds.Beep4     = Sound.new("delorean_beep_4" , false, 1.0, SpeedEvent.New("Beep", 55))
Delorean.Sounds.Beep5     = Sound.new("delorean_beep_5" , false, 1.0, SpeedEvent.New("Beep", 60))
Delorean.Sounds.Beep6     = Sound.new("delorean_beep_6" , false, 1.0, SpeedEvent.New("Beep", 65))
Delorean.Sounds.Beep7     = Sound.new("delorean_beep_7" , false, 1.0, SpeedEvent.New("Beep", 69))
Delorean.Sounds.Beep8     = Sound.new("delorean_beep_8" , false, 1.0, SpeedEvent.New("Beep", 73))
Delorean.Sounds.Beep9     = Sound.new("delorean_beep_9" , false, 1.0, SpeedEvent.New("Beep", 76))
Delorean.Sounds.Beep10    = Sound.new("delorean_beep_10", false, 1.0, SpeedEvent.New("Beep", 79))
Delorean.Sounds.Beep11    = Sound.new("delorean_beep_11", false, 1.0, SpeedEvent.New("Beep", 81))
Delorean.Sounds.Beep12    = Sound.new("delorean_beep_12", false, 1.0, SpeedEvent.New("Beep", 83))
Delorean.Sounds.Beep13    = Sound.new("delorean_beep_13", false, 1.0, SpeedEvent.New("Beep", 85))
Delorean.Sounds.Beep14    = Sound.new("delorean_beep_14", false, 1.0, SpeedEvent.New("Beep", 86))
Delorean.Sounds.Beep15    = Sound.new("delorean_beep_15", false, 0.0, SpeedEvent.New("Beep", 86))



---
-- Delorean sprites
---
Delorean.Sprites = {}
Delorean.Sprites.Main     = Sprite.New("textures/Characters/Vehicles/Delorean/Delorean/delorean.xml", 11)
Delorean.Sprites.Inner    = Sprite.New("textures/Characters/Vehicles/Delorean/Delorean/delorean_inside.xml", 9)
Delorean.Sprites.Tubes    = Sprite.New("textures/Characters/Vehicles/Delorean/Delorean/delorean_tubes_glow.xml", 11)
Delorean.Sprites.Glow     = GlowSprite.New("textures/Characters/Vehicles/Delorean/Delorean/delorean_blue_effect.xml", 11)
Delorean.Sprites.JetFlame1 = Sprite.New("textures/Vehicles/deloreanbooster.xml", 11)
Delorean.Sprites.JetFlame2 = Sprite.New("textures/Vehicles/deloreanbooster.xml", 11)
Delorean.Sprites.ShockFront = Sprite.New("textures/Characters/Vehicles/Delorean/Delorean/delorean_shock_front.xml", 11)

---
-- GetTextureList()
--  Called from cpp.
---
function Delorean.GetTextureList()
	return
		"textures/Characters/Vehicles/delorean/delorean/delorean_bg.tex" ..
		"|textures/Characters/Vehicles/Components/delorean/delorean/ComponentCar.tex" ..
		"|textures/Characters/Vehicles/Components/delorean/delorean/ComponentBack.tex" ..
		"|textures/Characters/Vehicles/Components/delorean/delorean/ComponentBottom.tex" ..
		"|textures/Characters/Vehicles/Components/delorean/delorean/ComponentTop.tex" ..
		"|textures/Characters/Vehicles/delorean/delorean/delorean_tubes_glow.tex" ..
		"|textures/Characters/Vehicles/delorean/delorean/delorean_blue_effect.tex" ..
		"|textures/vehicles/deloreanbooster.tex|speedUpWind1.tex"
end

function Delorean:BannerComplete()
	VehicleUtils.PlaySong(self, "music", "banner_complete")
end

---
-- PickupStart()
--  ???
---
function Delorean:PickupStart()
	Debug.Log(Debug.General, "Delorean:PickupStart")
	OffsetPickupComponents(2,18)
	SetFirstComponentToFront(true)
end

---
-- ComponentComplete
--  Called from cpp during construction, when one of the components has snapped in place.
---
function Delorean:ComponentComplete()
	Debug.Log(Debug.General, "Delorean:ComponentComplete")
end

---
-- ConstructionComplete()
--  Called from cpp, when the Delorean has finished being constructed.
---
function Delorean:ConstructionComplete()
	Debug.Log(Debug.General, "Delorean:ConstructionComplete")
	self.Sounds.FormComplete:Play()
	OffsetVehiclePosition(0,0)
	self:UpdateSpritePositions()

	VehicleUtils.PlaySong(self, "music", "construction_complete")
end

---
-- OnInit
--  Called from cpp when the Vehicle has just been Initialized.
--
-- Note: The Vehicle may be drawn before its first update.
--       So, make sure that its state is presentable.
---
function Delorean:OnInit(info)
	Debug.Log(Debug.General, "Delorean:OnInit")
	self.Base.OnInit(self, info)

	self:InitState()

	-- Load Main body
	self.Sprites.Main:Load()
	self.Sprites.Main:PlayAnimation("idle")

	self.Sprites.Inner:Load()

	-- Creating the Delorean additional textures for some extra visual effects.
	self.Sprites.Tubes:Load()
	self.Sprites.Glow:Load()

	-- JetFlame!
	self.Sprites.JetFlame1:Load()
	self.Sprites.JetFlame2:Load()

	-- Shock Front
	self.Sprites.ShockFront:Load()
	self.Sprites.ShockFront.isVisible = true
	self.Sprites.ShockFront:PlayAnimation("idle")

	-- Adjust JetFlame scale/alpha 1
	self.Sprites.JetFlame1.scale = Vector.New(1.0, 1.0)
	self.Sprites.JetFlame1.alpha = 1.0
	self.Sprites.JetFlame1.tweenAlpha = true
	self.Sprites.JetFlame1.tweenStartAlpha = 1.0
	self.Sprites.JetFlame1.tweenTargetAlpha = 0.0

	-- Adjust JetFlame scale/alpha 2
	self.Sprites.JetFlame2.scale = Vector.New(1.0, 1.0)
	self.Sprites.JetFlame2.alpha = 1.0
	self.Sprites.JetFlame2.tweenAlpha = true
	self.Sprites.JetFlame2.tweenStartAlpha = 1.0
	self.Sprites.JetFlame2.tweenTargetAlpha = 0.0

	-- Initial visible flags
	self.Sprites.Main.isVisible = true
	self.Sprites.Inner.isVisible = true
	self.Sprites.Tubes.isVisible = false
	self.Sprites.Glow:SetVisible(false)
	self.Sprites.JetFlame1.isVisible = false
	self.Sprites.JetFlame2.isVisible = false
	self.Sprites.ShockFront.isVisible = false

	-- Initial positions
	self:UpdateSpritePositions()

	-- Adding pickup components in a different order so that they draw correctly.
	--AddPickupComponent("textures/Characters/Vehicles/Components/delorean/delorean/ComponentCar.tex", 9, -1)
	--AddPickupComponent("textures/Characters/Vehicles/Components/delorean/delorean/ComponentBack.tex", 11, 1)
	--AddPickupComponent("textures/Characters/Vehicles/Components/delorean/delorean/ComponentBottom.tex", 11, 1)
	--AddPickupComponent("textures/Characters/Vehicles/Components/delorean/delorean/ComponentTop.tex", 11, 1)

	-- Initial state
	self:SetCurrentState(DeloreanState.None)

		-- Disable all particles
	self:DisableAllParticles()

	SetVehicleScreenShotRating(50)
end

---
-- Initialize or Reset the Vehicle's state
---
function Delorean:InitState()
	self.horizontalSpeed = Constants.SpeedingUp.startSpeed
	self.targetSpeed = Constants.SpeedingUp.targetSpeed
	self.startSpeed = Constants.SpeedingUp.startSpeed
	self.rotation = 0.0
	self.verticalSpeed = 0.0
	self.verticalAcceleration = 0.0
end

---
-- DisableAllParticles()
--  Does what it says.
---
function Delorean:DisableAllParticles()
	self.Particles.FireTyre:SetActive(false)
	self.Particles.TimeTravelStreaks2:SetActive(false)
	self.Particles.TimeTravelStreaks1:SetActive(false)
	self.Particles.DeloreanSparks:SetActive(false)
	self.Particles.DeloreanSparksBuildup:SetActive(false)
	self.Particles.DustCloud:SetActive(false)
	self.Particles.DeloreanFlash1:SetActive(false)
	self.Particles.DeloreanFlashEmitter2:SetActive(false)
	self.Particles.DeloreanFlashEmitter3:SetActive(false)
	self.Particles.DeloreanImplosion:SetActive(false)
	self.Particles.BlueDustCloud:SetActive(false)
	self.Particles.DeloreanMiniNoseCone:SetActive(false)
	self.Particles.DeloreanNoseCone:SetActive(false)
	self.Particles.DeloreanShootingSparksLow:SetActive(false)
	self.Particles.DeloreanShootingSparksHigh:SetActive(false)
	self.Particles.DeloreanExhaust:SetActive(false)
	self.Particles.DeloreanExhaustBoost:SetActive(false)
	self.Particles.DeloreanFloorVent:SetActive(false)
	self.Particles.DeloreanLightning:SetActive(false)

end

---
-- EnableAllParticles()
--  Does what it says.
---
function Delorean:EnableAllParticles()
	self.Particles.FireTyre:SetActive(true)
	self.Particles.TimeTravelStreaks2:SetActive(true)
	self.Particles.TimeTravelStreaks1:SetActive(true)
	self.Particles.DeloreanSparks:SetActive(true)
	self.Particles.DeloreanSparksBuildup:SetActive(true)
	self.Particles.DustCloud:SetActive(true)
	self.Particles.DeloreanFlash1:SetActive(true)
	self.Particles.DeloreanFlashEmitter2:SetActive(true)
	self.Particles.DeloreanFlashEmitter3:SetActive(true)
	self.Particles.DeloreanImplosion:SetActive(true)
	self.Particles.BlueDustCloud:SetActive(true)
	self.Particles.DeloreanMiniNoseCone:SetActive(true)
	self.Particles.DeloreanNoseCone:SetActive(true)
	self.Particles.DeloreanShootingSparksLow:SetActive(true)
	self.Particles.DeloreanShootingSparksHigh:SetActive(true)
	self.Particles.DeloreanExhaust:SetActive(true)
	self.Particles.DeloreanExhaustBoost:SetActive(true)
	self.Particles.DeloreanFloorVent:SetActive(true)
	self.Particles.DeloreanLightning:SetActive(true)

end

---
-- DestroyAllParticles()
--  Does what it says.
---
function Delorean:DestroyAllParticles()
	self.Particles.FireTyre:DestroyEmitter()
	self.Particles.TimeTravelStreaks2:DestroyEmitter()
	self.Particles.TimeTravelStreaks1:DestroyEmitter()
	self.Particles.DeloreanSparks:DestroyEmitter()
	self.Particles.DeloreanSparksBuildup:DestroyEmitter()
	self.Particles.DustCloud:DestroyEmitter()
	self.Particles.DeloreanFlash1:DestroyEmitter()
	self.Particles.DeloreanFlashEmitter2:DestroyEmitter()
	self.Particles.DeloreanFlashEmitter3:DestroyEmitter()
	self.Particles.DeloreanImplosion:DestroyEmitter()
	self.Particles.BlueDustCloud:DestroyEmitter()
	self.Particles.DeloreanMiniNoseCone:DestroyEmitter()
	self.Particles.DeloreanNoseCone:DestroyEmitter()
	self.Particles.DeloreanShootingSparksLow:DestroyEmitter()
	self.Particles.DeloreanShootingSparksHigh:DestroyEmitter()
	self.Particles.DeloreanExhaust:DestroyEmitter()
	self.Particles.DeloreanExhaustBoost:DestroyEmitter()
	self.Particles.DeloreanFloorVent:DestroyEmitter()
	self.Particles.DeloreanLightning:DestroyEmitter()
end

---
-- StopAllSounds()
--  Does what it says.
---
function Delorean:StopAllSounds()
	self.Sounds.FormComplete:Stop(0.05)
	self.Sounds.Engine      :Stop(0.05)
	self.Sounds.Rockets     :Stop(0.05)
	self.Sounds.RocketsStop :Stop(0.05)
	self.Sounds.TimeBuild   :Stop(0.05)
	self.Sounds.TimeEnter   :Stop(0.05)
	self.Sounds.TimeExit    :Stop(0.05)
	self.Sounds.Death       :Stop(0.05)
	self.Sounds.Tubes       :Stop(0.05)
	self.Sounds.BuildLP     :Stop(0.05)
	self.Sounds.Flash1      :Stop(0.05)
	self.Sounds.Flash2      :Stop(0.05)
	self.Sounds.Flash3      :Stop(0.05)
	self.Sounds.Beep1       :Stop(0.05)
	self.Sounds.Beep2       :Stop(0.05)
	self.Sounds.Beep3       :Stop(0.05)
	self.Sounds.Beep4       :Stop(0.05)
	self.Sounds.Beep5       :Stop(0.05)
	self.Sounds.Beep6       :Stop(0.05)
	self.Sounds.Beep7       :Stop(0.05)
	self.Sounds.Beep8       :Stop(0.05)
	self.Sounds.Beep9       :Stop(0.05)
	self.Sounds.Beep10      :Stop(0.05)
	self.Sounds.Beep11      :Stop(0.05)
	self.Sounds.Beep12      :Stop(0.05)
	self.Sounds.Beep13      :Stop(0.05)
	self.Sounds.Beep14      :Stop(0.05)
	self.Sounds.Beep15      :Stop(0.05)

	-- Go back to default track
	SFX.PlaySong("default", 2)
end

---
-- CloseHUD()
--  Turn off the Delorean BrickUI HUD
---
function Delorean:CloseHUD()
	BrickUI.InvokeTrigger("GameHud.bottomMiddle.Triggers.close88HUD")
end

---
-- PickupSequenceUpdate()
--  ???
---
function Delorean:PickupSequenceUpdate(dt)
	--Debug.Log(Debug.General, "Delorean:PickupSequenceUpdate> dt:" .. tostring(dt))
end

---
-- Ready()
--  ???
---
function Delorean:Ready(skipPickupSeq)
	Debug.Log(Debug.General, "Delorean:Ready")
end

---
-- RampUpSpeed (<previousStateConstants>, <currentStateConstants>)
--  Scales speed
--
---
function Delorean:RampUpSpeed(previousStateConstants, currentStateConstants)
	local speedMultiplierStart = previousStateConstants.speedMultiplier
	local speedMultiplierMax = currentStateConstants.speedMultiplier
	local speedDelta = self.State.time / self.State.maxTime
	local speedMultiplier = Lerp.Sin.Tween(speedMultiplierStart, speedMultiplierMax, speedDelta)
	self:SetSpeed(self.horizontalSpeed * Constants.horizontalSpeedMultiplier * speedMultiplier)
end

---
-- OnUpdate(dt)
--  Called from cpp, once per frame.
---
function Delorean:OnUpdate(dt)
	if (self.State.current == DeloreanState.None) then
		self:UpdateStateNone(dt)
	elseif (self.State.current == DeloreanState.Spawned) then
		self:UpdateStateSpawned(dt)
	elseif (self.State.current == DeloreanState.SpeedingUp) then
		self:UpdateStateSpeedingUp(dt)
	elseif (self.State.current == DeloreanState.Hit88Begin) then
		self:UpdateStateHit88Begin(dt)
	elseif (self.State.current == DeloreanState.Hit88Middle) then
		self:UpdateStateHit88Middle(dt)
	elseif (self.State.current == DeloreanState.Hit88End) then
		self:UpdateStateHit88End(dt)
	elseif (self.State.current == DeloreanState.Disappeared) then
		self:UpdateStateDisappeared(dt)
	elseif (self.State.current == DeloreanState.ReappearBegin) then
		self:UpdateStateReappearBegin(dt)
	elseif (self.State.current == DeloreanState.ReappearMiddle) then
		self:UpdateStateReappearMiddle(dt)
	elseif (self.State.current == DeloreanState.ReappearEnd) then
		self:UpdateStateReappearEnd(dt)
	elseif (self.State.current == DeloreanState.Dead) then
		-- We're dead, do nothing
	end

	if (self.State.current ~= DeloreanState.Dead) then
		self:FlushParticlePositions()

		self:UpdateSpritePositions()

		self:UpdateSprites(dt)

		-- updates the magnet particles
		UpdateVehicleParticles()

	end

end

---
-- FlushParticlePositions()
--  Calls Update on all particles.
---
function Delorean:FlushParticlePositions()

	-- Flush to emitters
	self.Particles.FireTyre:Update(self)
	self.Particles.TimeTravelStreaks2:Update(self)
	self.Particles.TimeTravelStreaks1:Update(self)
	self.Particles.DeloreanSparks:Update(self)
	self.Particles.DeloreanSparksBuildup:Update(self)
	self.Particles.DustCloud:Update(self)
	self.Particles.DeloreanFlash1:Update(self)
	self.Particles.DeloreanFlashEmitter2:Update(self)
	self.Particles.DeloreanFlashEmitter3:Update(self)
	self.Particles.DeloreanImplosion:Update(self)
	self.Particles.BlueDustCloud:Update(self)
	self.Particles.DeloreanMiniNoseCone:Update(self)
	self.Particles.DeloreanNoseCone:Update(self)
	self.Particles.DeloreanShootingSparksLow:Update(self)
	self.Particles.DeloreanShootingSparksHigh:Update(self)
	self.Particles.DeloreanExhaust:Update(self)
	self.Particles.DeloreanExhaustBoost:Update(self)
	self.Particles.DeloreanFloorVent:Update(self)
	self.Particles.DeloreanLightning:Update(self)
end

---
-- UpdateSpritePositions()
--  Updates all Sprite positions and rotations
---
function Delorean:UpdateSpritePositions()

	pos = Vector.New(GetPlayerPosition())

	self.Sprites.Main.pos = Vector.Clone(pos)
	self.Sprites.Inner.pos = Vector.Clone(pos)
	self.Sprites.Tubes.pos = Vector.Clone(pos)
	self.Sprites.Glow:SetPos(pos)

	-- Vertical engine flames 1
	if (self.Sprites.JetFlame1.isVisible) then

		self.Sprites.JetFlame1.scale = Vector.Clone(self.jetFlameScale)

		local scalePivot = Vector.New(32, -32)
		local jetFlamePos1 = (Vector.New(-44, -57) - scalePivot) * self.jetFlameScale + scalePivot
		local rotatedPos1 = VectorMath.RotateVector(jetFlamePos1, self.rotation)

		self.Sprites.JetFlame1.pos = pos + rotatedPos1
		self.Sprites.JetFlame1.rotation = self.rotation
	end

	-- Vertical engine flames 2
	if (self.Sprites.JetFlame2.isVisible) then

		self.Sprites.JetFlame2.scale = Vector.Clone(self.jetFlameScale)

		local scalePivot = Vector.New(32, -32)
		local jetFlamePos1 = (Vector.New(45, -57) - scalePivot) * self.jetFlameScale + scalePivot
		local rotatedPos2 = VectorMath.RotateVector(jetFlamePos1, self.rotation)

		self.Sprites.JetFlame2.pos = pos + rotatedPos2
		self.Sprites.JetFlame2.rotation = self.rotation
	end

	-- Shock Front
	if (self.Sprites.ShockFront.isVisible) then
		local shockFrontPos = Vector.New(75, -10)
		local rotatedShockFrontPos = VectorMath.RotateVector(shockFrontPos, self.rotation)
		self.Sprites.ShockFront.pos = pos + rotatedShockFrontPos
		self.Sprites.ShockFront.rotation = self.rotation
	end

	self.Sprites.Main.rotation = self.rotation
	self.Sprites.Inner.rotation = self.rotation
	self.Sprites.Tubes.rotation = self.rotation
	self.Sprites.Glow:SetRotation(self.rotation)
end

---
-- UpdateSprites(dt)
--
---
function Delorean:UpdateSprites(dt)
	self.Sprites.Main     :Update(dt)
	self.Sprites.Inner    :Update(dt)
	self.Sprites.Tubes    :Update(dt)
	self.Sprites.Glow     :Update(dt)
	self.Sprites.JetFlame1 :Update(dt)
	self.Sprites.JetFlame2 :Update(dt)
	self.Sprites.ShockFront:Update(dt)
	end

---
-- UpdateTouch()
--  Determines vertical acceleration, based on whether touch is down.
---
function Delorean:UpdateTouch(dt)
	local accel = 0
	if(self.isPressed)then
		accel = Constants.accelUp
	else
		accel = Constants.accelDown
	end

	self.verticalAcceleration = accel
end

---
-- UpdatePosition(<dt>)
--  Updates the Delorean's position, velocity, and rotation.
---
function Delorean:UpdatePosition(dt)
	pos = Vector.New(GetPlayerPosition())

	self.verticalSpeed = math.min(Constants.maxUp, math.max(Constants.maxDown, self.verticalSpeed + (self.verticalAcceleration * dt)))
	moveDist = self.verticalSpeed * dt

	local yMin = -112
	local yMax =  116
	local yHover = yMin + 15
	local newY = pos[2] + moveDist

	-- Clamp to yMax
	if (newY >= yMax and self.verticalSpeed > 0) then
		newY = yMax
		self.verticalSpeed = 0
	end

	-- Clamp to yMin
	if (newY <= yMin and self.verticalSpeed < 0) then
		newY = yMin
		self.verticalSpeed = 0
	end

	local screenSize = Vector.New(GetScreenSize())
	local PLAYER_MIN_XPOS = GetVehicleRestPosition()
	pos[1] = pos[1] + ((PLAYER_MIN_XPOS - pos[1]) * dt)
	pos[2] = newY
	SetPlayerPosition(pos[1], pos[2])

	-- Update rotation
	local maxAngleUp = 7
	local maxAngleDn = -4

	local desiredRotation = 0.0
	if (self.verticalSpeed > 0) then
		desiredRotation = maxAngleUp * self.verticalSpeed / Constants.maxUp
	elseif (self.verticalSpeed < 0) then
		desiredRotation = maxAngleDn * self.verticalSpeed / Constants.maxDown
	else
		desiredRotation = 0.0
	end

	-- Hover Springyness
	if (pos[2] < yHover) then
		-- Bleed off speed
		local springZero = yHover
		local springPos = pos[2]
		local springDisplacement = springPos - springZero
		local springConstant = 195
		local springAcceleration = 0.0 - springConstant * springDisplacement
		self.verticalSpeed = self.verticalSpeed + springAcceleration * dt

		-- Amortize Speed
		self.verticalSpeed = self.verticalSpeed * 0.8
	end

	-- Level out rotation near floor and ceiling
	local levelOut =
	{
		max = 64,
		min = -64,
	}

	-- Level out rotation (near ceiling)
	if (self.verticalSpeed > 0 and pos[2] > levelOut.max) then
		local delta = (pos[2] - levelOut.max) / (yMax - levelOut.max)
		local targetRotation = 0.0
		desiredRotation = Lerp.Sin.Tween(desiredRotation, targetRotation, delta)
	end

	-- Level out rotation (near floor)
	if (self.verticalSpeed < 0 and pos[2] < levelOut.min) then
		local delta = (levelOut.min - pos[2]) / (levelOut.min - yMin)
		local targetRotation = 0.0
		desiredRotation = Lerp.Sin.Tween(desiredRotation, targetRotation, delta)
	end

	self.rotation = Lerp.EaseOutSin.Tween(self.rotation, desiredRotation, 0.15)

	-- Engage Hover Engines (if visible)
	local deloreanVisible = self.State.current < DeloreanState.Hit88Begin or self.State.current > DeloreanState.Disappeared
	local hoverEngines = deloreanVisible and pos[2] < levelOut.min
	self.Particles.DeloreanFloorVent:SetActive(hoverEngines)

	-- Scale the tire boosters to fit on floor
	local JetFlameScale =
	{
		min = 0.1,
		max = 1.0,
		minY = yMin,
		maxY = yMin + 40,
	}
	local jetFlameScaleY = JetFlameScale.max
	if (pos[2] < JetFlameScale.maxY) then
		jetFlameScaleY = (pos[2] - JetFlameScale.minY) / (JetFlameScale.maxY - JetFlameScale.minY)
	end

	--self.jetFlameScale[2] = Lerp.Linear.Tween(self.jetFlameScale[2], jetFlameScaleY, 0.75)
	self.jetFlameScale[2] = jetFlameScaleY

end

--
-- CheckCurrentStateTime
--  Increments current state time.
--  Check if the current state time exceeds max time.
--  If so, transitions to next specified state.
--
function Delorean:CheckCurrentStateTime(dt, nextState)

	-- Increment current state time
	self.State.prevTime = self.State.time
	self.State.time = self.State.time + dt;

	-- Increment update count
	self.State.updateCount = self.State.updateCount + 1

	-- Check against max time
	if (self.State.maxTime > 0 and self.State.time > self.State.maxTime) then
		self:SetCurrentState(nextState)
	end
end

---
-- SetCurrentState(<nextState>)
--  Sets the current state.
--  If not already in that state, the time and updateCount are reset.
---
function Delorean:SetCurrentState(nextState)
	if (self.State.current == nextState) then
		Debug.Log(Debug.States, "Already in this state. " .. DeloreanState.Names[nextState])
	else
		self.State.current = nextState
		self.State.prevTime = 0.0
		self.State.time = 0.0
		self.State.updateCount = 0
		self.State.maxTime = DeloreanState.MaxTimes[nextState]

		Debug.Log(Debug.States, "Going into state " .. DeloreanState.Names[self.State.current] .. " maxTime: " .. self.State.maxTime)
	end
end

---
-- IsStateFirstUpdate
--  Returns TRUE if the currentStateUpdateCount is 0
---
function Delorean:IsStateFirstUpdate()
	local isFirst = (self.State.updateCount == 0)
	return isFirst
end

--
-- UpdateStateNone
--  UpdateState (None)
--
function Delorean:UpdateStateNone(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "Delorean state None, time to spawn")
		self:InitState()

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		-- Clear Immunity
		self:SetImmune(false)
		self:SetCollidable(true)

		SetGameTimerFrozen(false)

		-- Start Spawning
		Level.SetSpawningEnabled(true)

		if (self.Sounds.Engine.isActive == false) then
			-- Start Engine again
			self.Sounds.Engine:Play()
		end
	end

	self.SetUISpeedValue(self.horizontalSpeed)

	-- Update Vehicle's Speed
	self:SetSpeed(self.horizontalSpeed * Constants.horizontalSpeedMultiplier)

	self:CheckCurrentStateTime(dt, DeloreanState.Spawned)

		-- Pop up 88mph dash HUD.
	BrickUI.InvokeTrigger("GameHud.bottomMiddle.Triggers.open88HUD")

end

--
-- UpdateStateSpawned
--  UpdateState (Spawned)
--
function Delorean:UpdateStateSpawned(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "Delorean Spawned.")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		-- Clear Immunity
		self:SetImmune(false)
		self:SetCollidable(true)

		SetGameTimerFrozen(false)

		-- Start Spawning
		Level.SetSpawningEnabled(true)

		if (self.Sounds.Engine.isActive == false) then
			-- Start Engine again
			self.Sounds.Engine:Play()
		end
	end

	self.SetUISpeedValue(self.horizontalSpeed)

	-- Update Vehicle's Speed
	self:SetSpeed(self.horizontalSpeed * Constants.horizontalSpeedMultiplier)

	-- Handle Touch
	self:UpdateTouch(dt)

	-- Update pos
	self:UpdatePosition(dt)

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.SpeedingUp)

end

--
-- UpdateStateSpeedingUp
--  UpdateState (SpeedingUp)
--
function Delorean:UpdateStateSpeedingUp(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "Delorean state SpeedingUp")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		-- Clear Immunity
		self:SetImmune(false)
		self:SetCollidable(true)

		SetGameTimerFrozen(false)

		-- Start Spawning
		Level.SetSpawningEnabled(true)

		if (self.Sounds.Engine.isActive == false) then
			-- Start Engine again
			self.Sounds.Engine:Play()
		end
	end

	-- Start Engine again
	if (self.Sounds.Engine.isActive == false) then
		self.Sounds.Engine:Play()
	end

	-- backup previous speed
	local previousSpeed = self.horizontalSpeed

	-- Update speed
	if (self.State.maxTime > 0) then
		local delta = self.State.time / self.State.maxTime
		local desiredSpeed = Lerp.EaseOutSin.Tween(self.startSpeed, self.targetSpeed, delta)
		self.horizontalSpeed = desiredSpeed

		-- Check if we're near target (fixes time-delta issues)
		if ((self.horizontalSpeed + 0.5) > self.targetSpeed) then
			-- within range skip to it, this fixes issues with low dt's
			self.horizontalSpeed = self.targetSpeed
		end
	end

	-- Speed Event 1
	if (SpeedEvent1:Check(previousSpeed, self.horizontalSpeed)) then
		self:OnSpeedEvent1()
	end

	-- Speed Event 2
	if (SpeedEvent2:Check(previousSpeed, self.horizontalSpeed)) then
		self:OnSpeedEvent2()
	end

	-- Speed Event 3
	if (SpeedEvent3:Check(previousSpeed, self.horizontalSpeed)) then
		self:OnSpeedEvent3()
	end

	-- Speed Event 4
	if (SpeedEvent4:Check(previousSpeed, self.horizontalSpeed)) then
		self:OnSpeedEvent4()
	end

	-- Speed Event 5
	if (SpeedEvent5:Check(previousSpeed, self.horizontalSpeed)) then
		self:OnSpeedEvent5()
	end

	-- Beeps
	self.Sounds.Beep1 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep2 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep3 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep4 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep5 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep6 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep7 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep8 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep9 :CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep10:CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep11:CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep12:CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep13:CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep14:CheckSpeedEvent(previousSpeed, self.horizontalSpeed)
	self.Sounds.Beep15:CheckSpeedEvent(previousSpeed, self.horizontalSpeed)

	-- Update UI
	self.SetUISpeedValue(self.horizontalSpeed)

	-- Update Vehicle's Speed
	self:SetSpeed(self.horizontalSpeed * Constants.horizontalSpeedMultiplier)

	-- Handle Touch
	self:UpdateTouch(dt)

	-- Update pos
	self:UpdatePosition(dt)

		-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.Hit88Begin)
end

---
-- SpeedingUp Event 1
--
---
function Delorean:OnSpeedEvent1()
	Debug.Log(Debug.States, " SpeedEvent: " .. SpeedEvent1.eventName)

end

---
-- SpeedingUp Event 2
--
---
function Delorean:OnSpeedEvent2()
	Debug.Log(Debug.States, " SpeedEvent: " .. SpeedEvent2.eventName)

	-- Mini Lightning
	self.Particles.DeloreanLightning:SetActive(true)

	-- Fade in the blue tube glow texture over 5 secs.
	self.Sprites.Tubes.alpha = 0.0
	self.Sprites.Tubes.fadeInTime = 5.0
	self.Sprites.Tubes:FadeIn()

end

---
-- SpeedingUp Event 3
--
---
function Delorean:OnSpeedEvent3()
	Debug.Log(Debug.States, " SpeedEvent: " .. SpeedEvent3.eventName)

	-- Mini Nose Cone
	self.Particles.DeloreanMiniNoseCone:SetActive(true)
	self.Particles.DeloreanLightning:SetActive(true)

	-- 88mph dash HUD shake 1
	BrickUI.InvokeTrigger("GameHud.bottomMiddle.Triggers.shake88HUD1")

end

---
-- SpeedingUp Event 4
--
---
function Delorean:OnSpeedEvent4()
	Debug.Log(Debug.States, " SpeedEvent: " .. SpeedEvent4.eventName)

	-- Build up sparks
	self.Particles.DeloreanSparksBuildup:SetActive(true)
	self.Particles.DeloreanShootingSparksLow:SetActive(true)
	self.Particles.DeloreanLightning:SetActive(true)

	-- Screen shake
	Constants.SpeedingUp.HudShakes[1]:Shake()

	-- 88mph dash HUD shake 2
	BrickUI.InvokeTrigger("GameHud.bottomMiddle.Triggers.shake88HUD2")

	-- BuildLP sound
	self.Sounds.BuildLP:Play()
end

---
-- SpeedingUp Event 5
--
---
function Delorean:OnSpeedEvent5()
	Debug.Log(Debug.States, " SpeedEvent: " .. SpeedEvent5.eventName)

	-- Full sparks particle plays - 'delorean_sparks
	self.Particles.DeloreanSparks:SetActive(true)
	self.Particles.DeloreanNoseCone:SetActive(true)
	self.Particles.DeloreanExhaustBoost:SetActive(true)
	self.Particles.DeloreanShootingSparksHigh:SetActive(true)
	self.Particles.DeloreanLightning:SetActive(true)

	-- Shock Front
	self.Sprites.ShockFront.alpha = 0.0
	self.Sprites.ShockFront.fadeInTime = 4.5
	self.Sprites.ShockFront:FadeIn()

	-- 88mph dash HUD Shake 3
	BrickUI.InvokeTrigger("GameHud.bottomMiddle.Triggers.shake88HUD3")

	-- Screen shake
	Constants.SpeedingUp.HudShakes[2]:Shake()

	-- Small Fire Particles from tyres
	-- TODO

	-- Start full screen weak speed streaks particle
	self.Particles.TimeTravelStreaks1:SetActive(true)

	-- Building Up Sounds
	self.Sounds.TimeBuild:Play()
end

--
-- UpdateStateHit88Begin
--  UpdateState (Hit88Begin)
--
function Delorean:UpdateStateHit88Begin(dt)

	if (self:IsStateFirstUpdate()) then

		Debug.Log(Debug.States, "Hit88Begin.")

		-- Screen shake
		Constants.SpeedingUp.HudShakes[3]:Shake()

		-- EMP Blast
		--local shockwavePos = Vector.New(GetPlayerPosition())
		--Level.CreateShockwave(shockwavePos[1], shockwavePos[2])

		-- Speed boost 1.5 sec

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = true
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(true)
		self.Particles.DeloreanSparks        :SetActive(true)
		self.Particles.DeloreanSparksBuildup :SetActive(true)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(true)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(true)
		self.Particles.DeloreanExhaustBoost  :SetActive(true)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(true)

		-- Set Immunity
		self:SetImmune(true)
		self:SetCollidable(true)

		SetGameTimerFrozen(true)

		-- Clear all obstacles, stop spawning new ones
		Level.ClearObstacles()
		Level.ClearMissiles()
		Level.SetSpawningEnabled(false)

		-- time build here 12345

		-- Play Tubes SFX
		self.Sounds.Tubes:Play()

		if (self.Sounds.Engine.isActive == false) then
			-- Start Engine again
			self.Sounds.Engine:Play()
		end
	end

	-- Ramp up Vehicle's Speed
	self:RampUpSpeed(Constants.SpeedingUp, Constants.Hit88Begin)

	-- Handle Touch
	self:UpdateTouch(dt)

	-- Update pos
	self:UpdatePosition(dt)

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.Hit88Middle)
end

--
-- UpdateStateHit88Middle
--  UpdateState (Hit88Middle)
--
function Delorean:UpdateStateHit88Middle(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "Hit88Middle.")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = true
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(true)
		self.Particles.DeloreanSparks        :SetActive(true)
		self.Particles.DeloreanSparksBuildup :SetActive(true)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(true)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(true)
		self.Particles.DeloreanExhaustBoost  :SetActive(true)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(true)

		-- Set Immunity
		self:SetImmune(true)
		self:SetCollidable(true)

		SetGameTimerFrozen(true)

		-- Clear all obstacles, stop spawning new ones
		Level.ClearObstacles()
		Level.ClearMissiles()
		Level.SetSpawningEnabled(false)

		if (self.Sounds.Engine.isActive == false) then
			-- Start Engine again
			self.Sounds.Engine:Play()
		end
	end

	-- Ramp up Vehicle's Speed
	self:RampUpSpeed(Constants.Hit88Begin, Constants.Hit88Middle)

	-- Tubes now fully visivle
	self.Sprites.Tubes.alpha = 1.0

	-- Handle Touch
	self:UpdateTouch(dt)

	-- Update pos
	self:UpdatePosition(dt)

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.Hit88End)
end

--
-- UpdateStateHit88End
--  UpdateState (Hit88End)
--
function Delorean:UpdateStateHit88End(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "Hit88End.")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = true
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = true

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(true)
		self.Particles.DeloreanSparks        :SetActive(true)
		self.Particles.DeloreanSparksBuildup :SetActive(true)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(true)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(true)
		self.Particles.DeloreanExhaustBoost  :SetActive(true)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(true)

		-- Set Immunity
		self:SetImmune(true)
		self:SetCollidable(true)

		SetGameTimerFrozen(true)

		-- Clear all obstacles, stop spawning new ones
		Level.ClearObstacles()
		Level.ClearMissiles()
		Level.SetSpawningEnabled(false)
	end

	-- Ramp up Vehicle's Speed
	self:RampUpSpeed(Constants.Hit88Middle, Constants.Hit88End)

	-- Glow, Do a final glow just at the tail end
	local glowBegin = self.State.maxTime - Constants.GlowToDisappear.fadeIn.time
	if (self.State.prevTime < glowBegin and self.State.time >= glowBegin) then
		Log("GlowToDisappear!")
		self.Sprites.Glow:Animate( Constants.GlowToDisappear.fadeIn, Constants.GlowToDisappear.fadeOut, Constants.GlowToDisappear.posTween )
	end

	-- Tubes
	self.Sprites.Tubes.alpha = 1.0

	-- Effects: DustCloud
	local dustCloudTime = self.State.maxTime - 0.5
	if (self.State.time >= dustCloudTime) then
		self.Particles.DustCloud:SetActive(true)
	end

	-- Effects: Flash1
	local flash1time = self.State.maxTime - 0.5
	if (self.State.time >= flash1time) then
		-- FireTyre appears to share position with DeloreanFlash >_<
		-- Please make sure only one of them is active at a time.
		self.Particles.DeloreanFlash1:SetActive(true)
	end

	-- Effects: Implosion
	local implosionTime = self.State.maxTime - 0.3
	if (self.State.time >= implosionTime) then
		self.Particles.DeloreanImplosion:SetActive(true)
	end

	-- Handle Touch
	self:UpdateTouch(dt)

	-- TouchScale, calculate delta
	local touchScaleMax = self.State.maxTime + 15.0
	local touchScaleDelta = self.State.time / touchScaleMax
	touchScaleDelta = math.max(0.0, math.min(1.0, touchScaleDelta))

	-- Calculate touch scale
	local verticalAccelerationScale = Lerp.Linear.Tween(1.0, 0.0, touchScaleDelta)
	self.verticalAcceleration = self.verticalAcceleration * verticalAccelerationScale

	local verticalSpeedScale = Lerp.Linear.Tween(1.0, 0.0, touchScaleDelta)
	self.verticalSpeed = self.verticalSpeed * verticalSpeedScale

	-- Update pos
	self:UpdatePosition(dt)

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.Disappeared)

end

--
-- UpdateStateDisappeared
--  UpdateState (Disappeared)
--
function Delorean:UpdateStateDisappeared(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "Disappeared.")

		self:CloseHUD()

		self.Particles.FireTyre.targetPos = self.Particles.FireTyre.startPos + Vector.New(800.0, 0)

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(true)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(true)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanFloorVent     :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		-- Set sprite visibles
		self.Sprites.Main.isVisible = false
		self.Sprites.Inner.isVisible = false
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		Debug.Log(Debug.States, "Jump Begin!")
		self.startJumpDist = GetDistanceRun()

		-- Stop moving
		self:SetSpeed(0.0)

		-- Set Immunity
		self:SetImmune(true)
		self:SetCollidable(false)

		SetGameTimerFrozen(true)

		-- Clear all obstacles, stop spawning new ones
		Level.ClearObstacles()
		Level.ClearMissiles()
		Level.SetSpawningEnabled(false)

		local shockwavePos = Vector.New(GetPlayerPosition())
		Level.CreateShockwave(shockwavePos[1], shockwavePos[2], true)

		-- Hide Barry
		self:SetDrawHead(false)

		-- Hide Shadow
		self:SetDrawShadow(false)

		-- Hide Engine Jetflames
		self.Sprites.JetFlame1.isVisible = false
		self.Sprites.JetFlame2.isVisible = false

		Constants.Disappeared.hudShake:Shake()

		-- Teleport Enter
		self.Sounds.TimeEnter:Play()

		-- Stop BuildLP sound and Engine
		self.Sounds.BuildLP:Stop(0.05)
		self.Sounds.Engine:Stop(0.05)
	end

	-- Lerp FireTyre pos
	if (self.Particles.FireTyre.isActive) then

		-- When past tyreFireTime, Just keep moving forwards
		local tyreFireDelta = self.State.time / Constants.tyreFireTime
		local startPos      = self.Particles.FireTyre.startPos
		local targetPos     = self.Particles.FireTyre.targetPos

		local posDiff = targetPos - startPos

		-- Tween reverse-wraps for delta > 1.0, so instead we advance the animation by 100% for each wrapping
		while (tyreFireDelta > 1.0) do
			targetPos = targetPos + posDiff
			startPos = startPos + posDiff
			tyreFireDelta = tyreFireDelta - 1.0
		end

		local desiredPos = Vector.New(0, 0)
		desiredPos[1] = Lerp.EaseOutSin.Tween(startPos[1], targetPos[1], tyreFireDelta)
		desiredPos[2] = Lerp.EaseOutSin.Tween(startPos[2], targetPos[2], tyreFireDelta)

		self.Particles.FireTyre.pos = desiredPos
	end

-- Log("TireFire delta: " .. delta .. ", posX: " .. self.Particles.FireTyre.pos[1] .. ", posY: " .. self.Particles.FireTyre.pos[2])

	-- Disappeared stun or fast-forwards
	local movementStart = Constants.disappearedStunTime
	local movementEnd = self.State.maxTime - Constants.reappearStunTime
	if (self.State.time > movementStart and self.State.time <= movementEnd) then
		self.Particles.FireTyre:SetActive(false)

		local fastForwardTime     = self.State.time - movementStart
		local fastForwardMaxTime  = movementEnd - movementStart
		local fastForwardMaxSpeed = Constants.Disappeared.FastForward.speed

		local rampUpTime = Constants.Disappeared.FastForward.rampUpTime
		local rampDownTime = fastForwardMaxTime - Constants.Disappeared.FastForward.rampDownTime

		local fastForwardSpeed = 0.0

		if (fastForwardTime < rampUpTime) then
			-- Ramping speed up
			local ffSpeedDelta = fastForwardTime / rampUpTime
			fastForwardSpeed = Lerp.Sin.Tween(0.0, fastForwardMaxSpeed, ffSpeedDelta)
		elseif (fastForwardTime > rampDownTime) then
			-- Ramping speed down
			local ffSpeedDelta = (fastForwardTime - rampDownTime) / (fastForwardMaxTime - rampDownTime)
			fastForwardSpeed = Lerp.Sin.Tween(fastForwardMaxSpeed, 0.0, ffSpeedDelta)
		else
			-- Full throttle
			fastForwardSpeed = fastForwardMaxSpeed
		end

		self:SetSpeed(fastForwardSpeed * Constants.horizontalSpeedMultiplier)
		self.Particles.TimeTravelStreaks2:SetActive(true)
		self.Particles.TimeTravelStreaks1:SetActive(true)
	elseif (self.State.time > movementEnd) then
		self:SetSpeed(0.0)
		self.Particles.TimeTravelStreaks2:SetActive(false)
		self.Particles.TimeTravelStreaks1:SetActive(false)
	end

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.ReappearBegin)
end

--
-- UpdateStateReappearBegin
--  UpdateState (ReappearBegin)
--
function Delorean:UpdateStateReappearBegin(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "ReappearBegin.")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = false
		self.Sprites.Inner.isVisible = false
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(true)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(true)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		-- First Flash
		Constants.ReappearBegin.hudShake:Shake()

		-- Flash Glow 1
		self.Sprites.Glow:Animate( Constants.FlashGlow1.fadeIn, Constants.FlashGlow1.fadeOut, Constants.FlashGlow1.posTween )

		local shockwavePos = Vector.New(GetPlayerPosition())
		Level.CreateShockwave(shockwavePos[1], shockwavePos[2], true)

		-- Update Vehicle's Speed
		self:SetSpeed(0.0)

		-- Sound Flash 1
		self.Sounds.Flash1:Play()

		-- Set Immunity
		self:SetImmune(true)
		self:SetCollidable(false)

		SetGameTimerFrozen(true)

		-- Clear all obstacles, stop spawning new ones
		Level.ClearObstacles()
		Level.ClearMissiles()
		Level.SetSpawningEnabled(false)
	end

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.ReappearMiddle)
end

--
-- UpdateStateReappearMiddle
--  UpdateState (ReappearMiddle)
--
function Delorean:UpdateStateReappearMiddle(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "ReappearMiddle.")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = false
		self.Sprites.Inner.isVisible = false
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(true)
		self.Sprites.ShockFront.isVisible = false

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(false)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		-- Second Flash
		Constants.ReappearMiddle.hudShake:Shake()

		-- Flash Glow 2
		self.Sprites.Glow:Animate( Constants.FlashGlow1.fadeIn, Constants.FlashGlow1.fadeOut, Constants.FlashGlow1.posTween )

		local shockwavePos = Vector.New(GetPlayerPosition())
		Level.CreateShockwave(shockwavePos[1], shockwavePos[2], true)

		-- Update Vehicle's Speed
		self:SetSpeed(0.0)

		-- Sound Flash 2
		self.Sounds.Flash2:Play()

		-- Set Immunity
		self:SetImmune(true)
		self:SetCollidable(false)

		SetGameTimerFrozen(true)

		-- Clear all obstacles, stop spawning new ones
		Level.ClearObstacles()
		Level.ClearMissiles()
		Level.SetSpawningEnabled(false)
	else
		self.Particles.DeloreanFlashEmitter2:SetActive(true)
	end

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.ReappearEnd)
end

--
-- UpdateStateReappearEnd
--  UpdateState (ReappearEnd)
--
function Delorean:UpdateStateReappearEnd(dt)

	if (self:IsStateFirstUpdate()) then
		Debug.Log(Debug.States, "ReappearEnd.")

		-- Set sprite visibles
		self.Sprites.Main.isVisible = true
		self.Sprites.Inner.isVisible = true
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(true)
		self.Sprites.ShockFront.isVisible = false

		-- Fade Out Glow sprite
		self.Sprites.Glow:Animate( Constants.FlashGlowAppear.fadeIn, Constants.FlashGlowAppear.fadeOut, Constants.FlashGlowAppear.posTween )

		-- Set Particle States
		self.Particles.FireTyre              :SetActive(false)
		self.Particles.TimeTravelStreaks2    :SetActive(false)
		self.Particles.TimeTravelStreaks1    :SetActive(false)
		self.Particles.DeloreanSparks        :SetActive(false)
		self.Particles.DeloreanSparksBuildup :SetActive(false)
		self.Particles.DustCloud             :SetActive(false)
		self.Particles.DeloreanFlash1        :SetActive(false)
		self.Particles.DeloreanFlashEmitter2 :SetActive(false)
		self.Particles.DeloreanFlashEmitter3 :SetActive(false)
		self.Particles.DeloreanImplosion     :SetActive(false)
		self.Particles.BlueDustCloud         :SetActive(true)
		self.Particles.DeloreanMiniNoseCone  :SetActive(false)
		self.Particles.DeloreanNoseCone      :SetActive(false)
		self.Particles.DeloreanShootingSparksLow:SetActive(false)
		self.Particles.DeloreanShootingSparksHigh:SetActive(false)
		self.Particles.DeloreanExhaust       :SetActive(false)
		self.Particles.DeloreanExhaustBoost  :SetActive(false)
		self.Particles.DeloreanLightning     :SetActive(false)

		Constants.ReappearEnd.hudShake:Shake()

		-- Update Vehicle's Speed
		self:SetSpeed(Constants.reappearStartSpeed)

		-- Show Barry
		self:SetDrawHead(true)

		-- Show Shadow
		self:SetDrawShadow(true)

		-- Show Engine Jetflames
		self.Sprites.JetFlame1.isVisible = true
		self.Sprites.JetFlame2.isVisible = true

		local shockwavePos = Vector.New(GetPlayerPosition())
		Level.CreateShockwave(shockwavePos[1], shockwavePos[2], true)

		-- No longer immune
		self:SetImmune(false)
		self:SetCollidable(true)

		SetGameTimerFrozen(false)

		-- Teleport Exit
		self.Sounds.TimeExit:Play()

		-- Sound Flash 3
		self.Sounds.Flash3:Play()

		-- Start Spawning again
		Level.SetSpawningEnabled(true)
	end

	if (self.Sounds.Engine.isActive == false and self.State.time > Constants.reappearStartEngineTime) then
		-- Start Engine again
		self.Sounds.Engine:Play()
	end

	-- Handle Touch
	self:UpdateTouch(dt)

	-- Update pos
	self:UpdatePosition(dt)

	-- Check current state's time
	self:CheckCurrentStateTime(dt, DeloreanState.None)

	VehicleUpdateSpeed(dt)
end

---
-- OnDraw
--  Called from cpp
--  Draws all the things.
---
function Delorean:OnDraw()

	-- Draw Base Texture
	self.Sprites.Main:Draw()
	self.Sprites.Inner:Draw()

	-- Draw Tubes Texture
	self.Sprites.Tubes:Draw()

	-- Draw Glow Texture
	self.Sprites.Glow:Draw()

	-- Draw Jet Engines
	self.Sprites.JetFlame1:Draw()
	self.Sprites.JetFlame2:Draw()

	-- Shock Front
	self.Sprites.ShockFront:Draw()

end

---
-- GetShadowWidth
--  Returns the width of the drop shadow.
---
function Delorean:GetShadowWidth()
	return 157.0
end

---
-- GetPlayerRectangle(<coin>)
--  Returns the player's bounds. (right, bottom, left, top)
--
-- Note: forCoin does not seem to be "for coins".
--       It looks like it's for destructible level objects and lights. meh.
---
function Delorean:GetPlayerRectangle(forCoin)
	pos = Vector.New(GetPlayerPosition())
	return pos[1], pos[2], pos[1], pos[2] -- right, bottom, left, top
end

---
-- GetCollisionRectangle()
--  Returns the player's collision bounds (x, y, width, height)
---
function Delorean:GetCollisionRectangle()
	pos = Vector.New(GetPlayerPosition())
	return pos[1], pos[2], 6, 4 -- x pos, y pos, x extent, y extent
end

---
-- GetRenderOffset()
---
function Delorean:GetRenderOffset()
	return 0, 0
end

---
-- GetConstructionRenderFlags()
---
function Delorean:GetConstructionRenderFlags()
	return 6
end

---
-- GetRotation()
---
function Delorean:GetRotation()
	return self.rotation
end

---
-- TouchUp()
--  Called from cpp, when Touch is Up
---
function Delorean:TouchUp()
	self.Sounds.Rockets:Stop(0.05)
	self.Sounds.RocketsStop:Play()

	self.Sprites.JetFlame1:FadeOut()
	self.Sprites.JetFlame2:FadeOut()

	self.Particles.DeloreanExhaust:SetActive(false)

	self.isPressed = false
end

---
-- TouchDown()
--  Called from cpp, when Touch is Down
---
function Delorean:TouchDown()

	if (self.State.current < DeloreanState.Hit88End or self.State.current >= DeloreanState.ReappearEnd) then
		self.Sounds.Rockets:Play()
		self.Sprites.JetFlame1:FadeIn()
		self.Sprites.JetFlame2:FadeIn()
		self.Particles.DeloreanExhaust:SetActive(true)
	else
		self.Sprites.JetFlame1.isVisible = false
		self.Sprites.JetFlame2.isVisible = false
	end

	-- Testing Flash Glow 1
	-- Log("Testing Flash Glow 1")
	-- self.Sprites.Glow:Animate( Constants.FlashGlow1.fadeIn, Constants.FlashGlow1.fadeOut, Constants.FlashGlow1.posTween )
	-- Log("Testing GlowToDisappear")
	-- self.Sprites.Glow:Animate( Constants.GlowToDisappear.fadeIn, Constants.GlowToDisappear.fadeOut, Constants.GlowToDisappear.posTween )

	self.isPressed = true
end

---
-- Explode()
--  Called from cpp, when the Vehicle should blow up.
---
function Delorean:Explode()
	Debug.Log(Debug.General, "Delorean:Explode")
	self.Sounds.Death:Play()
	self:CloseAll()
end

---
-- OnDestroy()
--  Called from cpp, when the Vehicle has been destroyed.
---
function Delorean:OnDestroy()
	Debug.Log(Debug.General, "Delorean:OnDestroy")
	self.Base.OnDestroy(self)
	self:CloseAll()
end

---
-- CloseAll
--  Called on script close.
---
function Delorean:CloseAll()
	self:CloseHUD()
	self:StopAllSounds()
	self:DestroyAllParticles()
	self:SetCurrentState(DeloreanState.Dead)

	-- No longer immune, and is collidable
	self:SetImmune(false)
	self:SetCollidable(true)

	-- Start Spawning again
	Level.SetSpawningEnabled(true)
end

---
-- SaveState
--  Called on app suspend
---
function Delorean:SaveState(stateData)
	Debug.Log(Debug.General, "Delorean:SaveState");
	stateData.stateCurrent = self.State.current
	stateData.statePrevTime = self.State.prevTime
	stateData.stateTime = self.State.time
	stateData.stateUpdateCount = self.State.updateCount
	stateData.stateMaxTime = self.State.maxTime
end

---
-- LoadState
--  Called on app resume
---
function Delorean:LoadState(stateData)
	Debug.Log(Debug.General, "Delorean:LoadState");
	self.State.current = stateData.stateCurrent
	self.State.prevTime = stateData.statePrevTime
	self.State.time = stateData.stateTime
	self.State.updateCount = stateData.stateUpdateCount
	self.State.maxTime = stateData.stateMaxTime

	if (self.State.current == DeloreanState.Disappeared) then
		self.Sprites.Main.isVisible = false
		self.Sprites.Inner.isVisible = false
		self.Sprites.Tubes.isVisible = false
		self.Sprites.Glow:SetVisible(false)
		self.Sprites.ShockFront.isVisible = false

		SetGameTimerFrozen(true)

		-- Hide Barry
		self:SetDrawHead(false)

		-- Hide Shadow
		self:SetDrawShadow(false)
	end

	Debug.Log(Debug.General, "Delorean:State:");
	Debug.Log(Debug.General, "    self.State.current     = " .. tostring(self.State.current    ))
	Debug.Log(Debug.General, "    self.State.prevTime    = " .. tostring(self.State.prevTime   ))
	Debug.Log(Debug.General, "    self.State.time        = " .. tostring(self.State.time       ))
	Debug.Log(Debug.General, "    self.State.updateCount = " .. tostring(self.State.updateCount))
	Debug.Log(Debug.General, "    self.State.maxTime     = " .. tostring(self.State.maxTime    ))
end

RegisterVehicle("Delorean", "DeloreanBase", Delorean)
