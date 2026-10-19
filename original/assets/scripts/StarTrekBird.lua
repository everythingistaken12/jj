Log("StarTrekBird Lua script started")

OverloadVehicleSounds()

local StarTrekBird = {}
local birdBody
local birdSparks
local headPos
local birdGrind
local ground = -1
local playBirdGrind = -1


local fallingSound
local fallingSoundPlaying = false

function StarTrekBird.GetTextureList()
	return ""
end

function StarTrekBird.ComponentComplete()

end

function StarTrekBird.ConstructionComplete()
	headPos = Vector.New(GetPlayerPosition())
	SFX.PlaySound ("st_bird_form_complete")
end

function StarTrekBird.PickupStart()
	OffsetPickupComponents(-5,2)
end


function StarTrekBird:OnInit(info)
	self.Base.OnInit(self, info)
	birdGrind = -1
	OverloadVehicleSounds()
	SetBirdEffects(false)
	birdSparks = LoadTexture("textures/Effects/landSparksBird.xml", 11)
	fallingSoundPlaying = false	
end

function StarTrekBird.PickupSequenceUpdate(dt)
	Log("PickupSequenceUpdate")
end

function StarTrekBird.Ready(skipPickupSeq)
	Log("Ready")
	
	fallingSound = SFX.PlaySound("st_bird_fly_lp",true)
	fallingSoundPlaying = true
end

function StarTrekBird:OnUpdate(dt)
	self.Base.OnUpdate(self, dt)
	
end

function StarTrekBird:OnDraw()
	self.Base.OnDraw(self)
	headPos = Vector.New(GetPlayerPosition())
	sparksPos = Vector.Clone(headPos)
	worldPos = Vector.New(Level.GetOffset())

	if(IsDogActive() == true)then	
		petPosition = Vector.New(GetDogPosition())
	end
	
	if(ground == 1)then
		DrawTexture(birdSparks, sparksPos[1], sparksPos[2] - 8)
	end
end

function StarTrekBird.HitRoof()
	Log("HitRoof")
end

function StarTrekBird.HitGround()
	PlayAnimation(birdBody,"hitGround")
	PlayAnimation(birdSparks,"landsparks")
	SFX.PlaySound("medic_bird_land")
	ground = 1
	if(playBirdGrind == -1)then
		birdGrind = SFX.PlaySound("bird_slideLP",true)
		playBirdGrind = 1
	end
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	Log("HitGround")
end

function StarTrekBird.CloseToCoins()
	PlayAnimation(birdBody,"eat")

	if(componentSound == 1)then
		SFX.PlaySound("st_bird_vox_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("st_bird_vox_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("st_bird_vox_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("st_bird_vox_1")
	end		
end

function StarTrekBird.FarFromCoins()
	PlayAnimation(birdBody,"eatClose")
end

function StarTrekBird.TouchUp()
	if(fallingSoundPlaying == false)then
		fallingSound = SFX.PlaySound("st_bird_fly_lp",true)
		fallingSoundPlaying = true
	end
	Log("TouchUp")
	inputUp = true
end

function StarTrekBird.TouchDown()
	Log("TouchDown")
end

function StarTrekBird.Jump()
	componentSound = math.random(4)
	Log("randomFlap = "..componentSound)

	if(ground > 0)then
		PlayAnimation(birdBody,"offGround")
		
		ground = -1
	end	
	if(componentSound == 1)then
		SFX.PlaySound("st_bird_flap_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("st_bird_flap_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("st_bird_flap_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("st_bird_flap_1")
	end
	inputUp = false
	if(playBirdGrind == 1)then
		SFX.StopSound(birdGrind or -1,0.5)
		playBirdGrind = -1
	end
end

function StarTrekBird.Explode()
	Log("Explode")
	SFX.StopSound(fallingSound or -1,0.05)
	fallingSoundPlaying = false
	SFX.StopSound(birdGrind or -1)
	SFX.PlaySound("st_bird_explode")
	playBirdGrind = -1
end

function StarTrekBird:OnDestroy()
	Log("OnDestroy")
	SFX.StopSound(fallingSound or -1)
	
	self.Base.OnDestroy(self)
end

function LogVec(name, vec)
	Log(name..": "..vec[1]..", "..vec[2])
end

function StarTrekBird.FlashToAnim_vehicleNoFlap()

end

function StarTrekBird.FlashToAnim_Flap()
	dogFlap = math.random(3)

	componentSound = math.random(4)

	if(componentSound == 1)then
		SFX.PlaySound("st_bird_flap_1")
	elseif(componentSound == 2)then
		SFX.PlaySound("st_bird_flap_2")
	elseif(componentSound == 3)then
		SFX.PlaySound("st_bird_flap_3")
	elseif(componentSound == 4)then
		SFX.PlaySound("st_bird_flap_1")
	end

end

RegisterVehicle("StarTrekBird", "Bird", StarTrekBird);
