Log("ZappyBird Lua script started")

local ZappyBird = {}

local timeTillGate = 2
local timer = 0.0
local screenSize = Vector.New(GetScreenSize())
local spawnHeight = screenSize[2] * 0.9
local halfHeight = spawnHeight / 2
local halfGapSize = 150
local gapSize = halfGapSize * 2

local nothingType = 0
local coinsType = 1
local missileType = 2
local laserType = 3
local gateType = 4
local vehicleType = 5
local xOffsetMultiplier = 2
local randomDiagShrink = 1
local currentScore = 0
local spawnerChanceMax = 15
local spawnerChance = 1
local lastHurter = nil

function ZappyBird:OnReset()
	timeTillGate = 2
	randomDiagShrink = 1
	timer = timeTillGate
	currentScore = 0
	SFX.SetSongVolume(1.0)
	halfGapSize = 35
	gapSize = halfGapSize * 2
	spawnerChance = 1
	math.randomseed( os.time() )
end

function ZappyBird:OnGameUpdate(dt)
	if(IsPlayerDeadOrRevive()) then
		-- Make a delay before spawning next obstacle so that emp after revive can destroy all obstacles without counting them as passed,
		-- i.e if we spawn obstacle right after player is revived, then obstacle is killed with emp and it is counted as passing the obstacle.
		timer = 0.75
		return
	end

	if(currentScore == 5) then
		spawnerChance = 2
	end
	if(currentScore == 10)then
		spawnerChance = 6
	end
	if(currentScore > 15)then
		if(spawnerChance == 6) then
			spawnerChance = 7
		end
	end
	
	timer = timer - dt
	if(timer <= 0.0)then
	
	-- This is to make missiles and zappers have, at the very least, some space between each other.
		
		Log("SpawnChance = "..spawnerChance)
		if(spawnerChance >= 7 and spawnerChance < 9) then
			spawnerChance = spawnerChance + 1
			Log("SpawnChance UP! = "..spawnerChance)
		end
		
		randomSpawner = math.random(spawnerChance)
		if(randomSpawner == 1) then
			Log("SpawnZappyGate()")
			SpawnZappyGate()
			Log("Done")
		elseif (randomSpawner == 2) then
			Log("SpawnRandomCoinPattern()")
			SpawnRandomCoinPattern()
			Log("Done")
		elseif (randomSpawner == 4) then
			Log("SpawnZappyGateLong()")
			SpawnZappyGateLong()
			Log("Done")
		elseif (randomSpawner == 5) then
			Log("SpawnZappyGateDiagonal()")
			SpawnZappyGateDiagonal()
			Log("Done")
		elseif (randomSpawner == 6) then
			Log("SpawnZappyGateSpin()")
			SpawnZappyGateSpin()
			Log("Done")
		elseif (randomSpawner == 7) then
			Log("SpawnZappyGatePattern()")
			SpawnZappyGatePattern()
			Log("Done")
		elseif (randomSpawner == 8) then
			Log("SpawnRandMissile()")
			SpawnRandMissile()
			Log("Done")
			spawnerChance = 7
		end


		
		timeTillGate = timeTillGate * 0.99
		if(timeTillGate < 1.3) then
			timeTillGate = 1.3
		end
		
		halfGapSize = halfGapSize * 0.99
		
		if(halfGapSize < 25) then
			halfGapSize = 25
		end
	end
	
	playerPos = Vector.New(GetPlayerPosition())
	
	worldPos = Vector.New(Level.GetOffset())
	
	gapSize = halfGapSize * 2
	
	newScore = GetObstaclesCleared()
	if(currentScore ~= newScore) then
		diff = newScore - currentScore
		AddEventToken()
		Currency.AwardCurrency("ZappersPassed", diff)
		Currency.RefreshBank()

		StatisticsManager.IncrementEventTokenThisGame(1)
		StatisticsManager.IncrementEventTokenLifetime(1)

		currentScore = newScore
		SFX.PlaySound("count_light")
		CreateHiFive(playerPos[1]-worldPos[1] + 20, playerPos[2], 1.85)
	end
end

function ZappyBird:OnVehicleDestroyed(vehicle, didQuit)
	
	if(didQuit == false) then
		SFX.SetSongVolume(0.0)
		SFX.PlaySound("ZB_Death")
	end
	
	KillPlayer(lastHurter)
	ExplodePlayer(0)
	
	lastHurter = nil
end

function ZappyBird:OnPlayerHurt(hurter)
	lastHurter = hurter
end

function ZappyBird:OnObstacleSpawn(spawn_type)
	if(spawn_type == coinsType)then
		OverloadObstacleSpawn(nothingType)
	elseif(spawn_type == missileType)then
		OverloadObstacleSpawn(nothingType)
	elseif(spawn_type == laserType)then
		OverloadObstacleSpawn(nothingType)
	elseif(spawn_type == gateType)then
		OverloadObstacleSpawn(nothingType)
	elseif(spawn_type == vehicleType)then
		OverloadObstacleSpawn(nothingType)
	end
end

function ZappyBird:OnGameFinalised()
	SFX.SetSongVolume(1.0)
end

function ZappyBird:OnPlayerRevivedFinish(reviveType)
	ReviveWithVehicle()
end

function ReviveWithVehicle()
	Log("Respawning with Bird")
	GiveVehicle(4)
end

function SpawnZappyGateSquare()

	randLength = (math.random(halfGapSize, spawnHeight - gapSize))/2
	squareGateLength = spawnHeight - randLength
	
	x, y = GetPlayerPosition()
	xOffset = x + (xOffsetMultiplier * screenSize[1])
	
	ob1 = nil;ob2 = nil;ob4 = nil;ob4 = nil
	
	spawnSquareChance = 3
	
	if(currentScore > 10) then
		spawnSquareChance = 5
	end	
	
	randomGap = math.random(spawnSquareChance)
	
	if(randomGap == 1) then
		Log("Zappy Square 1")
		ob1 = EntityManager.SpawnObstacle(squareGateLength, xOffset, -90, 90)
		ob2 = EntityManager.SpawnObstacle(squareGateLength, xOffset, -45, 90)
		ob3 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 0, 90)
		ob4 = nil
	elseif(randomGap == 2) then
		Log("Zappy Square 2")
		ob1 = EntityManager.SpawnObstacle(squareGateLength, xOffset, -45, 90)
		ob2 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 0, 90)
		ob3 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 45, 90)
		ob4 = nil
	elseif(randomGap == 3) then
		Log("Zappy Square 3")
		ob1 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 0, 90)
		ob2 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 45, 90)
		ob3 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 90, 90)
		ob4 = nil
	elseif(randomGap == 4) then
		Log("Zappy Square 4")
		ob1 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 45, 90)
		ob2 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 0, 90)
		ob3 = EntityManager.SpawnObstacle(squareGateLength, xOffset, -45, 90)
		ob4 = EntityManager.SpawnObstacle(squareGateLength, xOffset, -90, 90)
	elseif(randomGap == 5) then
		Log("Zappy Square 5")
		ob1 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 90, 90)
		ob2 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 45, 90)
		ob3 = EntityManager.SpawnObstacle(squareGateLength, xOffset, 0, 90)
		ob4 = EntityManager.SpawnObstacle(squareGateLength, xOffset, -45, 90)
	end

	EntityManager.CreateScoreEntity(ob1, ob2, ob3, ob4)	
	
	-- As the gates are a little longer, add some temporary extra space for things to spawn afterwards
	timer = timeTillGate * 1.2
end

function SpawnZappyGateLong()

	randLength = (math.random(halfGapSize, spawnHeight - gapSize))/2
	longGateLength = spawnHeight - randLength
	
	x, y = GetPlayerPosition()
	xOffset = x + (xOffsetMultiplier * screenSize[1])
	
	spawnLongChance = 2
	
	if(currentScore > 10) then
		spawnLongChance = 6
	end
	if(currentScore > 15) then
		spawnLongChance = 10
	end	
		
	randomLongGateType = math.random(spawnLongChance)

	if(randomLongGateType <= 2) then
	Log("Zappy Long Gate 1")
		randomGap = math.random(3)
		ob1 = nil;ob2 = nil;ob3 = nil;ob4 = nil;ob5 = nil;ob6 = nil
		if(randomGap ~= 1) then
			Log("1")
			Log("2")
			ob2 = EntityManager.SpawnObstacle(longGateLength, xOffset, -90, 90)
		end
		if(randomGap ~= 2) then
			Log("3")
			Log("4")
			ob4 = EntityManager.SpawnObstacle(longGateLength, xOffset, 0, 90)
		end
		if(randomGap ~= 3) then
			Log("5")
			Log("6")
			ob6 = EntityManager.SpawnObstacle(longGateLength, xOffset, 90, 90)
		end
		
		ob7 = EntityManager.SpawnObstacle(longGateLength, xOffset, 135, 90)
		EntityManager.CreateScoreEntity(ob1, ob2, ob3, ob4, ob5, ob6, ob7)	
	elseif(randomLongGateType <= 6) then
		Log("Zappy Long Gate 2")
		randomGap = math.random(2,6)
		ob1 = nil;ob2 = nil;ob3 = nil;ob4 = nil;ob5 = nil;ob6 = nil;ob7 = nil
		if(randomGap ~= 1) then
			Log("1")
			ob1 = EntityManager.SpawnObstacle(longGateLength, xOffset, -135, 90)
		end
		if(randomGap ~= 2) then
			Log("2")
			ob2 = EntityManager.SpawnObstacle(longGateLength, xOffset, -90, 90)
		end
		if(randomGap ~= 3) then
			Log("3")
			ob3 = EntityManager.SpawnObstacle(longGateLength, xOffset, -45, 90)
		end
		if(randomGap ~= 4) then
			Log("4")
			ob4 = EntityManager.SpawnObstacle(longGateLength, xOffset, 0, 90)
		end
		if(randomGap ~= 5) then
			Log("5")
			ob5 = EntityManager.SpawnObstacle(longGateLength, xOffset, 45, 90)
		end
		if(randomGap ~= 6) then
			Log("6")
			ob6 = EntityManager.SpawnObstacle(longGateLength, xOffset, 90, 90)
		end
		if(randomGap ~= 7) then
			Log("7")
			ob7 = EntityManager.SpawnObstacle(longGateLength, xOffset, 135, 90)
		end
		
		EntityManager.CreateScoreEntity(ob1, ob2, ob3, ob4, ob5, ob6, ob7)

	elseif(randomLongGateType <= 10) then
		Log("Zappy Long Gate 3")
		randomGap = math.random(2,3)
		randomGap2 = math.random(4,6)
		ob1 = nil;ob2 = nil;ob3 = nil;ob4 = nil;ob5 = nil;ob6 = nil;ob7 = nil
		if(randomGap ~= 1 and randomGap2 ~= 1) then
			Log("1")
			ob1 = EntityManager.SpawnObstacle(longGateLength, xOffset, -135, 90)
		end
		if(randomGap ~= 2 and randomGap2 ~= 2) then
			Log("2")
			ob2 = EntityManager.SpawnObstacle(longGateLength, xOffset, -90, 90)
		end
		if(randomGap ~= 3 and randomGap2 ~= 3) then
			Log("3")
			ob3 = EntityManager.SpawnObstacle(longGateLength, xOffset, -45, 90)
		end
		if(randomGap ~= 4 and randomGap2 ~= 4) then
			Log("4")
			ob4 = EntityManager.SpawnObstacle(longGateLength, xOffset, 0, 90)
		end
		if(randomGap ~= 5 and randomGap2 ~=5 ) then
			Log("5")
			ob5 = EntityManager.SpawnObstacle(longGateLength, xOffset, 45, 90)
		end
		if(randomGap ~= 6 and randomGap2 ~= 6) then
			Log("6")
			ob6 = EntityManager.SpawnObstacle(longGateLength, xOffset, 90, 90)
		end
		if(randomGap ~= 7 and randomGap2 ~= 7) then
			Log("7")
			ob7 = EntityManager.SpawnObstacle(longGateLength, xOffset, 135, 90)
		end
		
		EntityManager.CreateScoreEntity(ob1, ob2, ob3, ob4, ob5, ob6, ob7)

	end

	-- As the gates are a little longer, add some temporary extra space for things to spawn afterwards
	timer = timeTillGate * 1.2
end

function SpawnZappyGatePattern()

	x, y = GetPlayerPosition()

	randomAngle = math.random(-60, 60)
	randomPosition = math.random(-60, 60)
	
	spawnChance = 2
	
	if(currentScore > 10) then
		spawnChance = 5
	end
	
	randomPatternZappy = math.random(spawnChance)
	xOffset = x + (xOffsetMultiplier * screenSize[1])
	ob1 = nil;ob2 = nil;ob4 = nil;ob4 = nil;ob5 = nil
	
	if (randomPatternZappy == 1) then
		Log("Zappy Gate Pattern 1")
		ob1 = EntityManager.SpawnObstacle(80, xOffset, randomPosition ,0)
		ob2 = EntityManager.SpawnObstacle(120, (xOffset + 40), randomPosition, 0)
		ob3 = EntityManager.SpawnObstacle(120, (xOffset + 80), randomPosition, 0)
		ob4 = EntityManager.SpawnObstacle(80, (xOffset + 120), randomPosition, 0)
		ob5 = nil
	elseif (randomPatternZappy == 2) then
		Log("Zappy Gate Pattern 2")
		ob1 = EntityManager.SpawnObstacle(200, xOffset, randomPosition,0)
		ob2 = EntityManager.SpawnObstacle(100, (xOffset + 60), randomPosition, 0)
		ob3 = EntityManager.SpawnObstacle(200, (xOffset + 120), randomPosition, 0)
		ob4 = EntityManager.SpawnObstacle(100, (xOffset + 180), randomPosition, 0)
		ob5 = EntityManager.SpawnObstacle(200, (xOffset + 240), randomPosition, 0)
	elseif (randomPatternZappy == 3) then
		Log("Zappy Gate Pattern 3")
		ob1 = EntityManager.SpawnObstacle(150, xOffset, randomPosition ,0)
		ob2 = EntityManager.SpawnObstacle(180, (xOffset + 40), randomPosition, 0)
		ob3 = EntityManager.SpawnObstacle(210, (xOffset + 80), randomPosition, 0)
		ob4 = EntityManager.SpawnObstacle(180, (xOffset + 120), randomPosition, 0)
		ob5 = EntityManager.SpawnObstacle(150, (xOffset + 160), randomPosition, 0)
	elseif (randomPatternZappy == 4) then
		Log("Zappy Gate Pattern 4")
		ob1 = EntityManager.SpawnObstacle(200, xOffset, randomPosition ,0)
		ob2 = EntityManager.SpawnObstacle(150, (xOffset + 40), randomPosition, 0)
		ob3 = EntityManager.SpawnObstacle(100, (xOffset + 80), randomPosition, 0)
		ob4 = EntityManager.SpawnObstacle(150, (xOffset + 120), randomPosition, 0)
		ob5 = EntityManager.SpawnObstacle(200, (xOffset + 160), randomPosition, 0)
	elseif (randomPatternZappy == 5) then
		Log("Zappy Gate Pattern 4")
		ob1 = EntityManager.SpawnObstacle(100, xOffset, randomPosition ,0)
		ob2 = EntityManager.SpawnObstacle(120, (xOffset + 40), randomPosition, 0)
		ob3 = EntityManager.SpawnObstacle(140, (xOffset + 80), randomPosition, 0)
		ob4 = EntityManager.SpawnObstacle(160, (xOffset + 120), randomPosition, 0)
		ob5 = EntityManager.SpawnObstacle(180, (xOffset + 160), randomPosition, 0)
	end
	EntityManager.CreateScoreEntity(ob1, ob2, ob3, ob4, ob5)
	
	timer = timeTillGate * 1.2
end

function SpawnZappyGateDiagonal()

	gapPosition = math.random(halfGapSize, spawnHeight - gapSize)
	lengthTop = spawnHeight - (gapPosition + halfGapSize)
	lengthBot = gapPosition - halfGapSize
	
	x, y = GetPlayerPosition()

	
	randomDiagSpace = math.random(55, 60)
	randomDiagSpace = randomDiagSpace *	randomDiagShrink
	if(randomDiagSpace < 45) then
		randomDiagSpace = 45
	end
	randomDiagShrink = randomDiagShrink * 0.99
	
	spawnChance = 1
	diagAngle = 80
	
	if(currentScore > 15) then
		spawnChance = 7
		diagAngle = 70
	end	
	
	randomDiagAngle = math.random(diagAngle, 90)
	randomDiagZappy = math.random(spawnChance)
	
	if(randomDiagAngle < 75) then
		DiagXOffset = x + (xOffsetMultiplier * screenSize[1])
	else
		DiagXOffset =	x + (xOffsetMultiplier * screenSize[1])
	end

		
	if (randomDiagZappy == 1) then
		Log("Zappy Diagonal 1")
		ob1 = EntityManager.SpawnObstacle(300, DiagXOffset, -randomDiagSpace, randomDiagAngle)
		ob2 = EntityManager.SpawnObstacle(300, DiagXOffset , randomDiagSpace, randomDiagAngle)
		EntityManager.CreateScoreEntity(ob1, ob2)
	elseif (randomDiagZappy == 2) then
		Log("Zappy Diagonal 2")
		ob1 = EntityManager.SpawnObstacle(300, DiagXOffset, randomDiagSpace, -randomDiagAngle)
		ob2 = EntityManager.SpawnObstacle(300, DiagXOffset, -randomDiagSpace, -randomDiagAngle)
		EntityManager.CreateScoreEntity(ob1, ob2)
	elseif (randomDiagZappy >= 3) then
		Log("Zappy Diagonal 3")
		ob1 = EntityManager.SpawnObstacle(300, DiagXOffset, -randomDiagSpace, -randomDiagAngle)
		ob2 = EntityManager.SpawnObstacle(300, DiagXOffset, randomDiagSpace, -randomDiagAngle)
		EntityManager.CreateScoreEntity(ob1, ob2)
	end
	
	timer = timeTillGate * 1.2
end

function SpawnZappyGateSpin()

	gapPosition = math.random(halfGapSize, spawnHeight - gapSize)
	lengthTop = spawnHeight - (gapPosition + halfGapSize)
	lengthBot = gapPosition - halfGapSize
	
	x, y = GetPlayerPosition()
	xOffset = x + (xOffsetMultiplier * screenSize[1])
	
	randomGap = math.random(9)
	Log("randomGap")
	
	rotationSpeed = math.random(0.5,1.5)
	if(lengthTop < 60 or lengthBot < 60) then
		rotationSpeed = 0
	end
	
	ob1 = nil;ob2 = nil
	if (randomGap == 1) then
		Log("Zappy Spin 1")
		ob1 = EntityManager.SpawnObstacle(100, xOffset, -90, 90, 1)
		ob2 = EntityManager.SpawnObstacle(100, xOffset, 90, 90, -1)
		EntityManager.CreateScoreEntity(ob1, ob2)
	elseif (randomGap == 2) then
		Log("Zappy Spin 2")
		ob1 = EntityManager.SpawnObstacle(150, xOffset, -90, 90, 1.1)
		ob2 = EntityManager.SpawnObstacle(150, xOffset, 90, 90, -1.1)
		EntityManager.CreateScoreEntity(ob1, ob2)
	elseif (randomGap == 3) then
		Log("Zappy Spin 3")
		if (lengthTop > 60) then 
			ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight) 
		end
		if (lengthBot > 60) then 
			ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight,0,rotationSpeed)
		end
		EntityManager.CreateScoreEntity(ob1, ob2)
		
	elseif (randomGap == 4) then
		Log("Zappy Spin 4")
		if (lengthTop > 60) then 
			ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight,0,rotationSpeed) 
		end
		if (lengthBot > 60) then 
			ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight)
		end
		EntityManager.CreateScoreEntity(ob1, ob2)
		
	elseif (randomGap == 5) then
		Log("Zappy Spin 5")
		if (lengthTop > 60) then 
			ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight) 
		end
		if (lengthBot > 60) then 
			ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight,0, -rotationSpeed)
		end
		EntityManager.CreateScoreEntity(ob1, ob2)
		
	elseif (randomGap == 6) then
		Log("Zappy Spin 6")
		if (lengthTop > 60) then 
			ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight,0,-rotationSpeed) 
		end
		if (lengthBot > 60) then 
			ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight)
		end
		EntityManager.CreateScoreEntity(ob1, ob2)
		
	elseif (randomGap == 7) then
		Log("Zappy Spin 7")
		if (lengthTop > 60) then 
			ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight,0,-rotationSpeed) 
		end
		if (lengthBot > 60) then 
			ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight,0,-rotationSpeed)
		end
		EntityManager.CreateScoreEntity(ob1, ob2)
		
	elseif (randomGap == 8) then
		Log("Zappy Spin 8")
		if (lengthTop > 60) then 
			ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight,0,-0.5) 
		end
		if (lengthBot > 60) then 
			ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight,0,0.5)
		end
		EntityManager.CreateScoreEntity(ob1, ob2)

	elseif (randomGap == 9) then
		Log("Zappy Spin 9")
		ob1 = EntityManager.SpawnObstacle(150, xOffset, -90, 100, -1.1)
		ob2 = EntityManager.SpawnObstacle(150, xOffset, 90, 100, 1.1)
		EntityManager.CreateScoreEntity(ob1, ob2)
	end
	
	timer = timeTillGate
end

function SpawnZappyGate()
	gapPosition = math.random(halfGapSize, spawnHeight - gapSize)
	lengthTop = spawnHeight - (gapPosition + halfGapSize)
	lengthBot = gapPosition - halfGapSize

	x, y = GetPlayerPosition()
	xOffset = x + (xOffsetMultiplier * screenSize[1])
	Log("Zappy Gate!")
	ob1 = nil; ob2 = nil
	if(lengthTop > 60) then
		ob1 = EntityManager.SpawnObstacle(lengthTop, xOffset, (gapPosition + halfGapSize + (lengthTop/2))-halfHeight)
	end
	if(lengthBot > 60) then
		ob2 = EntityManager.SpawnObstacle(lengthBot, xOffset, (gapPosition - halfGapSize - (lengthBot/2))-halfHeight)
	end
	EntityManager.CreateScoreEntity(ob1, ob2)
	timer = timeTillGate
end


function SpawnRandomCoinPattern()
	x, y = GetPlayerPosition() - Level.GetOffset()
	xOffset = x + (xOffsetMultiplier * screenSize[1])
	
	pattern = math.random(0, 14)
	Log("Coins")
	EntityManager.SpawnCoins(pattern, xOffset)
	
	timer = timeTillGate
end


function SpawnLazerGrid()
	x, y = GetPlayerPosition()
	xOffset = x + ((xOffsetMultiplier * 1.5) * screenSize[1])
	Log("Lazers!")	
	randomLazer = math.random(0,4)
	EntityManager.SpawnLazer(randomLazer, xOffset, true, 1.5)
	
	timer = 3.5
end

function SpawnRandMissile()

	spawnChance = 1
	
	if(currentScore > 25) then
		spawnChance = 3
	end	
	
	randomMissileSpawner = math.random(spawnChance)
	
	ob1 = nil;ob2 = nil;ob3 = nil;ob4 = nil;ob5 = nil;ob6 = nil;ob7 = nil
	if(randomMissileSpawner <= 1) then
		Log("Missiles 1")	
		randomGap = math.random(1,3)
		
		if(randomGap ~= 1) then
			ob1 = EntityManager.SpawnMissile(-135.0)
			ob2 = EntityManager.SpawnMissile(-90.0)
		end
		if(randomGap ~= 2) then
			ob3 = EntityManager.SpawnMissile(-45.0)
			ob4 = EntityManager.SpawnMissile(0.0)
		end
		if(randomGap ~= 3) then
			ob5 = EntityManager.SpawnMissile(45.0)
			ob6 = EntityManager.SpawnMissile(90.0)
		end
		ob7 = EntityManager.SpawnMissile(135.0)
	elseif(randomMissileSpawner <= 3) then
		Log("Missiles 2")
		randomGap = math.random(2,6)
		if(randomGap ~= 1) then
			ob1 = EntityManager.SpawnMissile(-135.0)
		end
		if(randomGap ~= 2) then
			ob2 = EntityManager.SpawnMissile(-90.0)
		end
		if(randomGap ~= 3) then
			ob3 = EntityManager.SpawnMissile(-45.0)
		end
		if(randomGap ~= 4) then
			ob4 = EntityManager.SpawnMissile(0.0)
		end
		if(randomGap ~= 5) then
			ob5 = EntityManager.SpawnMissile(45.0)
		end
		if(randomGap ~= 6) then
			ob6 = EntityManager.SpawnMissile(90.0)
		end
		if(randomGap ~= 7) then
			ob7 = EntityManager.SpawnMissile(135.0)
		end
	end
	
	EntityManager.CreateScoreEntity(ob1, ob2, ob3, ob4, ob5, ob6, ob7)
	timer = 2.5
end

RegisterGameRules("ZappyBird", "GameRules", ZappyBird);
