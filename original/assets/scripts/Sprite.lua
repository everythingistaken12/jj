Log("Sprite Lua script started v1.0.01")

---
-- Sprite class
--- 
Sprite = {}

---
-- Sprite Constructor
---
function Sprite.New(assetPath, drawLayer)

	---
	-- Init new Sprite
	---
	local newSprite =
	{
		sprite = nil,
		isVisible = false,
		pos = Vector.New(0,0),
		rotation = 0.0,
		scale = Vector.New(1,1),
		alpha = 1.0,
		tweenAlpha = false,
		tweenStartAlpha = 0.0,
		tweenTargetAlpha = 1.0,
		time = 0.0,
		maxTime = -1.0,
		fadeInTime = 0.1,
		fadeOutTime = 0.25,
	}
	newSprite.assetPath = assetPath
	newSprite.drawLayer = drawLayer

	---
	-- Load function
	---
	function newSprite:Load()
		self.sprite = LoadTexture(self.assetPath, self.drawLayer)
	end

	---
	-- PlayAnimation
	---
	function newSprite:PlayAnimation(animName)
		PlayAnimation(self.sprite, animName)
	end

	function newSprite:StopAnimation(animName)
		StopAnimation_(self.sprite)
	end

	function newSprite:ResetTime()
		self.time = 0.0
	end

	function newSprite:IsAnimating()
		return IsAnimating_(self.sprite)
	end

	---
	-- Update Function
	---
	function newSprite:Update(dt)
		self.time = self.time + dt

		if (self.maxTime > 0 and self.tweenAlpha) then
			local alphaDelta = self.time / self.maxTime
			alphaDelta = math.min(1.0, math.max(alphaDelta, 0.0))

			self.alpha = Lerp.Sin.Tween(self.tweenStartAlpha, self.tweenTargetAlpha, alphaDelta)
		end
	end

	---
	-- Draw function
	---
	function newSprite:Draw()
		if (self.isVisible) then
			local alpha = self.alpha
			if (alpha > 0) then
				DrawTexture(self.sprite, self.pos[1], self.pos[2], self.rotation, self.scale[1], self.scale[2], alpha)
			end
		end
	end

	---
	-- FadeIn function
	---
	function newSprite:FadeIn()
		self.isVisible = true
		self.time = 0.0
		self.maxTime = self.fadeInTime
		self.tweenAlpha = true
		self.tweenStartAlpha = self.alpha
		self.tweenTargetAlpha = 1.0
		self:PlayAnimation("idle")
		self:ResetTime()
	end

	---
	-- FadeOut function
	---
	function newSprite:FadeOut()
		if (self.isVisible) then
			self.time = 0.0
			self.maxTime = self.fadeOutTime
			self.tweenAlpha = true
			self.tweenStartAlpha = self.alpha
			self.tweenTargetAlpha = 0.0
			self:PlayAnimation("die")
			self:ResetTime()
		end
	end

	return newSprite
end
