class_name MapGenerator

#Generates maze
#After generating, removes random walls with amount `removeWalls` 
static func generateMap(sizeX: int, sizeY: int, removeWalls: int = 0) -> PackedInt32Array:
			#TODO: optimize by using 2 arrays like in BE
	# +- Up to 2_100_000_000 (explanation below)
	# 0_000_xxx_yyy
	# 0_1zz_xxx_yyy players positions, zz = playerId
	# 1_000_xxx_yyy vertical wall positions - (max = size x - 1)
	# 2_000_xxx_yyy horizontal wall positions | (max = field size y - 1)
	var possibleWalls := createPossibleWalls(sizeX, sizeY)
	
	var resultWalls: PackedInt32Array = []
	var currecntWallIndex: int = 0
	for possibleWall in possibleWalls:
		resultWalls.append(possibleWall)
		if checkConnection(possibleWall, resultWalls, sizeX, sizeY):
			#print("Wall addded: " + str(possibleWall))
			currecntWallIndex = currecntWallIndex + 1
		else:
			resultWalls.remove_at(currecntWallIndex)
			#print("Wall not addded: " + str(possibleWall))
	if removeWalls > 0 && resultWalls.size() > removeWalls:
		for wtr in removeWalls:
			resultWalls.remove_at(0)
	return resultWalls

@warning_ignore("INTEGER_DIVISION")
static func checkConnection(addedWall: int, currentWalls: PackedInt32Array, sizeX: int, sizeY: int) -> bool:
	#print("calculating for wall: " + str(addedWall))
	var positionsToSearchFrom: Array[Vector2i]= []
	var posToSearchX: int
	var posToSearchY: int
	@warning_ignore("UNASSIGNED_VARIABLE")
	var checkedPositions: PackedInt32Array
	if addedWall < 2_000_000_000:												#Vertical wall
		var mainBlockX = (addedWall - 1_000_000_000) / 1_000
		var mainBlockY = (addedWall - 1_000_000_000) % 1_000
		checkedPositions.append(mainBlockX * 1000 + mainBlockY)
		posToSearchX = mainBlockX + 1
		posToSearchY = mainBlockY
		if mainBlockY != 1 && currentWalls.find(2_000_000_000 + mainBlockX * 1_000 + mainBlockY - 1) == -1: 
			positionsToSearchFrom.append(Vector2i(mainBlockX, mainBlockY - 1))
			checkedPositions.append(mainBlockX*1000 + mainBlockY - 1)
		if mainBlockY != sizeY && currentWalls.find(2_000_000_000 + mainBlockX * 1_000 + mainBlockY) == -1: 
			positionsToSearchFrom.append(Vector2i(mainBlockX, mainBlockY + 1))
			checkedPositions.append(mainBlockX*1000 + mainBlockY + 1)
		if mainBlockX != 1 && currentWalls.find(1_000_000_000 + (mainBlockX - 1) * 1_000 + mainBlockY) == -1: 
			positionsToSearchFrom.append(Vector2i(mainBlockX - 1, mainBlockY))
			checkedPositions.append((mainBlockX - 1) * 1000 + mainBlockY)
	else:																		#Horizontal walls
		var mainBlockX = (addedWall - 2_000_000_000) / 1_000		#Extract
		var mainBlockY = (addedWall - 2_000_000_000) % 1_000
		checkedPositions.append(mainBlockX * 1000 + mainBlockY)
		posToSearchX = mainBlockX
		posToSearchY = mainBlockY + 1
		if mainBlockX != 1 && currentWalls.find(1_000_000_000 + (mainBlockX - 1) * 1_000 + mainBlockY) == -1: 
			positionsToSearchFrom.append(Vector2i(mainBlockX - 1, mainBlockY))
			checkedPositions.append((mainBlockX - 1) * 1000 + mainBlockY)
		if mainBlockX != sizeX && currentWalls.find(1_000_000_000 + mainBlockX * 1_000 + mainBlockY) == -1: 
			positionsToSearchFrom.append(Vector2i(mainBlockX + 1, mainBlockY))
			checkedPositions.append((mainBlockX + 1) * 1000 + mainBlockY)
		if mainBlockY != 1 && currentWalls.find(2_000_000_000 + mainBlockX * 1_000 + mainBlockY - 1) == -1:  
			positionsToSearchFrom.append(Vector2i(mainBlockX, mainBlockY - 1))
			checkedPositions.append(mainBlockX * 1000 + mainBlockY - 1)
	
	for position in positionsToSearchFrom:
		#print("New search______________________")
		#print(positionsToSearchFrom)
		#print(position)
		var posX = position.x
		var posY = position.y
		
		var nextWall: int 
		if posX > 1:
			nextWall = (posX - 1) * 1000 + posY									#Left
			if checkedPositions.find(nextWall) == -1 && currentWalls.find(1_000_000_000 + nextWall) == -1:
				if posToSearchX == posX - 1 && posToSearchY == posY: 
					return true
				positionsToSearchFrom.append(Vector2i(posX - 1, posY))
				checkedPositions.append(nextWall)
		
		if posX < sizeX:
			nextWall = posX * 1000 + posY									#Right
			if checkedPositions.find(nextWall + 1000) == -1 && currentWalls.find(1_000_000_000 + nextWall) == -1:
				if posToSearchX == posX + 1 && posToSearchY == posY: 
					return true
				positionsToSearchFrom.append(Vector2i(posX + 1, posY))
				checkedPositions.append(nextWall + 1000)
		
		if posY < sizeY:													#Bottom
			nextWall = posX * 1000 + posY
			if checkedPositions.find(nextWall + 1) == -1 && currentWalls.find(2_000_000_000 + nextWall) == -1:
				if posToSearchX == posX && posToSearchY == posY + 1: 
					return true
				positionsToSearchFrom.append(Vector2i(posX, posY + 1))
				checkedPositions.append(nextWall + 1)
		
		if posY != 1:															#Top
			nextWall = posX * 1000 + posY - 1
			if checkedPositions.find(nextWall) == -1 && currentWalls.find(2_000_000_000 + nextWall) == -1:
				if posToSearchX == posX && posToSearchY == posY - 1: 
					return true
				positionsToSearchFrom.append(Vector2i(posX, posY - 1))
				checkedPositions.append(nextWall)
	#print(false)
	return false

static func createPossibleWalls(sizeX: int, sizeY: int) -> PackedInt32Array:
	var array_to_shuffle: Array = []
	for x in range(1000, (sizeX + 1) * 1000, 1000):
		for y in range(1, sizeY):
			array_to_shuffle.append(x + y + 2_000_000_000)
	for x in range(1000, sizeX * 1000, 1000):
		for y in range(1, sizeY + 1):
			array_to_shuffle.append(x + y + 1_000_000_000)
	array_to_shuffle.shuffle()
	return PackedInt32Array(array_to_shuffle)

static func findPath(fromPosX: int, fromPosY: int, toPosX: int, toPosY: int, mapSizeX: int, mapSizeY: int, walls:PackedInt32Array) -> Array:
	if fromPosX == toPosX and fromPosY == toPosY: return [fromPosX * 1000 + fromPosY]
	var positionsToCheck := [[fromPosX, fromPosY]]
	var pathDict := {}
	for positionUnderCheck in positionsToCheck:
		var posX: int = positionUnderCheck[0]
		var posY: int = positionUnderCheck[1]
		if posX != mapSizeX:
			if walls.find(1_000_000_000 + posX * 1000 + posY) == -1:
				var nextPosX = posX + 1
				if positionsToCheck.find([nextPosX, posY]) == -1:
					pathDict[nextPosX * 1000 + posY] = posX * 1000 + posY
					if nextPosX == toPosX && posY == toPosY:
						return findPathFromDict(pathDict, fromPosX * 1000 + fromPosY, nextPosX * 1000 + posY)
					positionsToCheck.append([nextPosX, posY])
		if posX != 1:
			if walls.find(1_000_000_000 + (posX - 1) * 1000 + posY) == -1:
				var nextPosX = posX - 1
				if positionsToCheck.find([nextPosX, posY]) == -1:
					pathDict[nextPosX * 1000 + posY] = posX * 1000 + posY
					if nextPosX == toPosX && posY == toPosY:
						return findPathFromDict(pathDict, fromPosX * 1000 + fromPosY, nextPosX * 1000 + posY)
					positionsToCheck.append([nextPosX, posY])
		if posY != 1:
			if walls.find(2_000_000_000 + posX * 1000 + posY - 1) == -1:
				var nextPosY = posY - 1
				if positionsToCheck.find([posX, nextPosY]) == -1:
					pathDict[posX * 1000 + nextPosY] = posX * 1000 + posY
					if posX == toPosX && nextPosY == toPosY:
						return findPathFromDict(pathDict, fromPosX * 1000 + fromPosY, posX * 1000 + nextPosY)
					positionsToCheck.append([posX, nextPosY])
		if posY != mapSizeY:
			if walls.find(2_000_000_000 + posX * 1000 + posY) == -1:
				var nextPosY = posY + 1
				if positionsToCheck.find([posX, nextPosY]) == -1:
					pathDict[posX * 1000 + nextPosY] = posX * 1000 + posY
					if posX == toPosX && nextPosY == toPosY:
						return findPathFromDict(pathDict, fromPosX * 1000 + fromPosY, posX * 1000 + nextPosY)
					positionsToCheck.append([posX, nextPosY])
	MyLogger.log_warning("Couldn't find path from " + str([fromPosX, fromPosY]) + " to " + str([toPosX, toPosY]) + " with walls: " + str(walls))
	return []

static func findPathFromDict(dict: Dictionary, fromPosId: int, toPosId: int) -> Array:
	var currentPosId = toPosId
	var resultArray = []
	resultArray.append(toPosId)
	while currentPosId != fromPosId:
		var nextPos = dict[currentPosId]
		currentPosId = nextPos
		resultArray.append(nextPos)
	resultArray.reverse()
	return resultArray
