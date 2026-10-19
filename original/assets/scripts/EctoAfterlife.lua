Log("EctoAfterlife Lua script started v1.0.0")

EctoConstants = {
    GroundLevel = -97.0,
    ShooterOffsetY = -15.0,
    ShootingDistance = 200.0,
    ShowLasso = true
}

function MakeEctoAfterlife()
	local skin = "EctoAfterlife"

	local skinFolder = EctoBuilder.GetSkinFolder(skin)
	local EctoAfterlife = EctoBuilder.Build(skin)

	EctoAfterlife.Sprites.Closed = Sprite.New(skinFolder.."ecto.xml", 11)
	EctoAfterlife.Sprites.Opened = Sprite.New(skinFolder.."ecto_open.xml", 11)
	EctoAfterlife.Sprites.Seat   = Sprite.New(skinFolder.."seat.xml", 11)

	EctoAfterlife.Sprites.Closed.scale = Vector.Clone(EctoAfterlife.scale)
	EctoAfterlife.Sprites.Opened.scale = Vector.Clone(EctoAfterlife.scale)
	EctoAfterlife.Sprites.Seat.scale   = Vector.Clone(EctoAfterlife.scale)

	EctoAfterlife.Sounds.ProtonStart = Sound.new("ecto_proton_start")
	EctoAfterlife.Sounds.ProtonLoop  = Sound.new("ecto_proton_lp", true)
	EctoAfterlife.Sounds.ProtonStop  = Sound.new("ecto_proton_stop")
	EctoAfterlife.Sounds.DoorClose   = Sound.new("ecto_sidedoor_close")
	EctoAfterlife.Sounds.DoorOpen    = Sound.new("ecto_sidedoor_open")

	EctoAfterlife.isShooting = false
	EctoAfterlife.isClosed = true
	EctoAfterlife.isClosing = false
	EctoAfterlife.isOpening = false
	EctoAfterlife.initialDoorOpenDelay = -1.0

	local baseTextureList = EctoAfterlife.GetTextureList()
	function EctoAfterlife.GetTextureList()
		return baseTextureList..
			"|"..skinFolder.."ecto_open.tex"..
			"|"..skinFolder.."ecto_seatanimation.tex"..
			"|textures/Effects/Jetpack/Proton/protonStream2.tex"..
			"|textures/Effects/Jetpack/Proton/coil1.tex"
	end

	local baseOnInit = EctoAfterlife.OnInit
	function EctoAfterlife:OnInit(info)
		baseOnInit(self, info)
		self.Sprites.Closed:Load()
		self.Sprites.Opened:Load()
		self.Sprites.Seat:Load()
		self.Sprites.Closed.isVisible = true
		self.Sprites.Opened.isVisible = true
		self.Sprites.Seat.isVisible = false

		local posX, posY = GetPlayerPosition()
		self.ProtonRay = LoadProtonRay(posX, posY + EctoConstants.ShooterOffsetY, 1.0, 0.0, EctoConstants.ShootingDistance, EctoConstants.ShowLasso)
		SetProtonRayLayer(self.ProtonRay, 12)

		math.randomseed(os.time())
		math.random()
		math.random()
		math.random()
	end

	local baseStopAllSounds = EctoAfterlife.StopAllSounds
	function EctoAfterlife:StopAllSounds()
		baseStopAllSounds(self)
		self.Sounds.ProtonLoop:Stop(0.05)
	end

	local baseOnUpdate = EctoAfterlife.OnUpdate
	function EctoAfterlife:OnUpdate(dt)
		if self.isBursting then
			self.Sprites.Main = self.Sprites.Closed
			if not self.isClosed then
				if self.isClosing then
					if not self.Sprites.Seat:IsAnimating() then
						self.Sprites.Seat.isVisible = false
						self.isClosing = false
						self.isClosed = true
					end
				else
					if not self.Sprites.Seat:IsAnimating() then
						self.Sprites.Seat.isVisible = true
						self.Sprites.Seat:PlayAnimation("close")
						self.isClosing = true
						EctoAfterlife.Sounds.DoorClose:Play()
					end
				end
			end
		else
			if not self.isClosed then
				self.Sprites.Main = self.Sprites.Opened
			else
				self.Sprites.Main = self.Sprites.Closed
				if self.isOpening then
					if not self.Sprites.Seat:IsAnimating() then
						self.Sprites.Seat.isVisible = false
						self.Sprites.Main = self.Sprites.Opened
						self.isOpening = false
						self.isClosed = false
					end
				else
					if not self.Sprites.Seat:IsAnimating() and self.initialDoorOpenDelay < 0.0 then
						self.Sprites.Seat.isVisible = true
						self.Sprites.Seat:PlayAnimation("open")
						self.isOpening = true
						EctoAfterlife.Sounds.DoorOpen:Play()
					end
				end
			end
		end

		if self.initialDoorOpenDelay > 0.0 then
			self.initialDoorOpenDelay = self.initialDoorOpenDelay - dt
			if self.initialDoorOpenDelay < 0.0 then
				self.Sprites.Seat.isVisible = true
				self.Sprites.Seat:PlayAnimation("open")
				self.isOpening = true
				EctoAfterlife.Sounds.DoorOpen:Play()
			end
		end

		baseOnUpdate(self, dt)

		local posX, posY = GetPlayerPosition()

		self.Sprites.Seat.pos = Vector.New(posX - 29, posY - 14)
		self.Sprites.Seat.rotation = self.rotation
		self.Sprites.Seat:Update(dt)

		local isShooting = false
		if posY < EctoConstants.GroundLevel and not self.isBursting then
			if not self.isClosed and not self.isOpening then
				isShooting = true
			end
		end

		UpdateProtonRay(self.ProtonRay, posX, posY + EctoConstants.ShooterOffsetY, isShooting)

		if self.isShooting and not isShooting then
			EctoAfterlife.Sounds.ProtonStop:Play()
		end

		if not self.isShooting and isShooting then
			EctoAfterlife.Sounds.ProtonStart:Play()
		end

		if self.isShooting and isShooting then
			if not EctoAfterlife.Sounds.ProtonLoop.isActive then
				EctoAfterlife.Sounds.ProtonLoop:Play()
			end
		else
			EctoAfterlife.Sounds.ProtonLoop:Stop(0.05)
		end

		self.isShooting = isShooting
	end

	local baseOnDraw = EctoAfterlife.OnDraw
	function EctoAfterlife:OnDraw()
		DrawProtonRay(self.ProtonRay)
		baseOnDraw(self)
		self.Sprites.Seat:Draw()
	end

	local baseConstructionComplete = EctoAfterlife.ConstructionComplete
	function EctoAfterlife:ConstructionComplete()
		baseConstructionComplete(self)
		self.initialDoorOpenDelay = 0.5
	end

	local baseCloseAll = EctoAfterlife.CloseAll
	function EctoAfterlife:CloseAll()
		baseCloseAll(self)
		print("EctoAfterlife:CloseAll()")
		self.Sprites.Seat:StopAnimation()
		self.isClosed = true
	end

	return EctoAfterlife
end

RegisterVehicle("EctoAfterlife", "EctoBase", MakeEctoAfterlife())
