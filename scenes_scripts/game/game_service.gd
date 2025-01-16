class_name GameService extends Node2D

var gameUI: GameUI
var webService: WebService

var _pathToField: Node
var _pathToPlayers: Node
var _pathToObjects: Node

var playerTank = preload("res://scenes/player/tank.tscn").instantiate()
var wallForCreation = preload("res://scenes/field/wall.tscn").instantiate()
#TODO: Create a special class to create maps and move this scenes there 
var circleSprite = preload("res://resources/circle_sprite.tscn").instantiate()
var squareSprite = preload("res://resources/square_sprite.tscn").instantiate()
var artefactScene = preload("res://scenes/field/objects/artefact.tscn").instantiate()
var playerBaseScene = preload("res://scenes/field/objects/base.tscn").instantiate()

var thisGameId: int = 0
var thisPlayerInfo: PlayerGameInfoDto
var thisPlayerStartingPosition: Array
var thisPlayerTank: BasicTank
var previousActions: Array

var playersAlive: int = 0
var playersInGame: int = 0

# Array[Array[bool]]
var gameField: Array[Array] = []
var horizontalWalls: Array[Array] = []
var verticalWalls: Array[Array] = []

var shouldCalculateScore := false
var gameState: Enums.GameState = Enums.GameState.PRE_GAME

func _init() -> void:
	Global.gameService = self

func _ready() -> void:
	_pathToField = $Field
	_pathToPlayers = $Players
	_pathToObjects = $Objects
	webService = Global.webService
	gameUI = Global.gameUI

func loadGame(game: GameDTO) -> bool:
	if game == null: return false
	shouldCalculateScore = false
	cleanField()
	Global.gameUI.resetUI()
	thisGameId = game.gameId
	setCameraScale(game.field.sizeX, game.field.sizeY)
	calculateField(game.field)
	hideNonField(game.field)
	makeFieldWalls(game.field)
	setTimerTime(game)
	var playersDictionary: Dictionary = createPlayersDictionary(game.players)
	prepareObjects(game.field.objectsPositions, playersDictionary)
	createReplays(game.players)
	
	## Determine what should be done with this replay and add corresponding game label
	if game.gameFinished || thisPlayerInfo == null:
		gameUI.setGameHintLabel("Watching game record")
		return true
	if game.gameTurn != thisPlayerInfo.turnsCompleted:
		createMainPlayer()
		gameUI.setGameHintLabel("Record your turn!")
	else: 
		for p in game.players:
			if p.turnsCompleted != game.gameTurn:
				gameUI.setGameHintLabel("Watching game record")
				return true
		if game.gameCreatorId == Global.playerId:
			gameUI.setGameHintLabel("As a game owner, you have to watch and detect the winner of the round")
			shouldCalculateScore = true
	return true

func startGame():
	playersAlive = playersInGame
	for n in _pathToObjects.get_children():
		if !n.is_in_group("Base"):
			n.reset()
	for n in _pathToPlayers.get_children():
		if n.is_in_group("Tank"):
			n.makeTankAlive()
		if n.is_in_group("Bullet"):
			n.queue_free()
	gameState = Enums.GameState.GAME

func createMainPlayer():
	playersInGame += 1
	var new_tank = playerTank.duplicate()
	new_tank.name = "Player"
	new_tank.modulate = Color.from_string(thisPlayerInfo.color, Color.WHITE)
	new_tank.get_node("TankController").set_script(load("res://scenes_scripts/player/player_control/singlePlayerControl.gd"))
	new_tank.position = Vector2(50 + thisPlayerStartingPosition[1] * 100, 50 + thisPlayerStartingPosition[0] * 100)
	new_tank.startingPosition = Vector2(50 + thisPlayerStartingPosition[1] * 100, 50 + thisPlayerStartingPosition[0] * 100)
	_pathToPlayers.add_child(new_tank)
	thisPlayerTank = new_tank
	new_tank.inGamePlayerId = thisPlayerInfo.inGamePlayerId

func setCameraScale(sizeX: int, sizeY: int):
	var pixelsX: float = (sizeX + 2) * 100
	var pixelsY: float = (sizeY + 2) * 100
	var window_size = get_viewport().size
	var scaleForX: float = window_size.x / pixelsX
	var scaleForY: float = window_size.y / pixelsY
	if scaleForX > scaleForY:
		$GameCamera.zoom = Vector2(scaleForY, scaleForY)
	else:
		$GameCamera.zoom = Vector2(scaleForX, scaleForX)
	$GameCamera.enabled = true

func createPlayersDictionary(players: Array[PlayerGameInfoDto]) -> Dictionary:
	var result: Dictionary = {}
	for player in players:
		result[player.inGamePlayerId] = player
		if player.playerId == Global.playerId:
			thisPlayerInfo = player
	return result

func prepareObjects(objPositions: Array, players: Dictionary):
	for objPos: Array in objPositions:
		var thisPlayerId: int = objPos[2]
		var player: PlayerGameInfoDto = players[thisPlayerId]
		var positionType: Enums.PositionType = Enums.PositionType.PLAYER_SPAWN
		if objPos.size() > 3:
			positionType = objPos[3]
		
		match positionType:
			Enums.PositionType.PLAYER_SPAWN:
				var newPlayerBase = playerBaseScene.duplicate()
				newPlayerBase.forTeam = player.inGamePlayerId
				_pathToObjects.add_child(newPlayerBase)
				newPlayerBase.position = Vector2(50 + objPos[1] * 100, 50 + objPos[0] * 100)
				newPlayerBase.name = "playerBase" + str(objPos[2])
				newPlayerBase.modulate = Color.from_string(player.color, Color.WHITE)
				if player.playerId == Global.playerId:
					thisPlayerStartingPosition = objPos
			Enums.PositionType.ARTEFACT:
				var newArtefact = artefactScene.duplicate()
				newArtefact.forTeam = player.inGamePlayerId
				_pathToObjects.add_child(newArtefact)
				newArtefact.position = Vector2(50 + objPos[1] * 100, 50 + objPos[0] * 100)
				newArtefact.startingPos = Vector2(50 + objPos[1] * 100, 50 + objPos[0] * 100)
				newArtefact.name = "Artefact" + str(objPos[2])
				newArtefact.modulate = Color.from_string(player.color, Color.WHITE)
			_:
				Logger.log_error("Strange object position found: " + str(positionType))
				var newCircle = circleSprite.duplicate()
				_pathToObjects.add_child(newCircle)
				newCircle.position = Vector2(50 + objPos[1] * 100, 50 + objPos[0] * 100)
				newCircle.name = "circleSprite" + str(objPos[2])
				newCircle.modulate = Color.from_string(player.color, Color.WHITE)

# TODO: make normal time, currently only x*y
func setTimerTime(game: GameDTO):
	$TimerOfGameEnd.wait_time = game.field.sizeX * game.field.sizeY

func getGameTimer() -> Timer:
	return Global.verifyObjectIsNotNullAndReturnIt($TimerOfGameEnd)

func makeFieldWalls(mapInfo: MapInfo):
	var mapSizeX: int = mapInfo.sizeX
	var mapSizeY: int = mapInfo.sizeY
	
	for xId in range(1, mapSizeX + 1):		#horizontal wall creation
		var wall = wallForCreation.duplicate()
		_pathToField.add_child(wall)
		wall.name = "TopWall" + str(xId)
		wall.position = Vector2(xId * 100 + 50, 100)
		
		wall = wallForCreation.duplicate()
		_pathToField.add_child(wall)
		wall.name = "BottomWall" + str(xId)
		wall.position = Vector2(xId * 100 + 50, 100 * mapSizeY + 100)
	for yId in range(1, mapSizeY + 1):		#vertical wall creation
		var wall = wallForCreation.duplicate()
		wall.set_rotation_degrees(90)
		_pathToField.add_child(wall)
		wall.name = "LeftWall" + str(yId)
		wall.position = Vector2(100, 100 * yId + 50)
		
		wall = wallForCreation.duplicate()
		wall.set_rotation_degrees(90)
		_pathToField.add_child(wall)
		wall.name = "RightWall" + str(yId)
		wall.position = Vector2(mapSizeX * 100 + 100, 100 * yId + 50)
	
	var verticalWalls: Array = mapInfo.verticalWallsPositions
	for wallCoordinate in verticalWalls:
		var yId = wallCoordinate[0]
		var xId = wallCoordinate[1]
		var wall = wallForCreation.duplicate()
		wall.set_rotation_degrees(90)
		_pathToField.add_child(wall)
		wall.name = "VerticalWall" + str(yId) + "_" + str(xId)
		wall.position = Vector2(200 + 100 * xId, 100 * yId + 150)
	
	var horizontalWalls: Array = mapInfo.horizontalWallsPositions
	for wallCoordinate in horizontalWalls:
		var yId = wallCoordinate[0]
		var xId = wallCoordinate[1]
		var wall = wallForCreation.duplicate()
		_pathToField.add_child(wall)
		wall.name = "VerticalWall" + str(yId) + "_" + str(xId)
		wall.position = Vector2(150 + 100 * xId, 200 + yId * 100)

func hideNonField(mapInfo: MapInfo):
	for y in mapInfo.sizeY:
		for x in mapInfo.sizeX:
			if !gameField[y][x]:
				var rX = x + 1
				var rY = y + 1
				var newHiddenSpot = squareSprite.duplicate()
				_pathToField.add_child(newHiddenSpot)
				newHiddenSpot.position = Vector2(50 + rX * 100, 50 + rY * 100)
func calculateField(mapInfo: MapInfo):
	gameField = []
	horizontalWalls = []
	verticalWalls = []
	
	for y in mapInfo.sizeY:
		var arrayY: Array[bool] = []
		for x in mapInfo.sizeX:
			arrayY.append(false)
		gameField.append(arrayY)
	gameField[mapInfo.objectsPositions[0][0] - 1][mapInfo.objectsPositions[0][1] - 1] = true
	
	for y in mapInfo.sizeY - 1:
		var arrayY: Array[bool] = []
		for x in mapInfo.sizeX:
			arrayY.append(false)
		horizontalWalls.append(arrayY)
	for wall in mapInfo.horizontalWallsPositions:
		horizontalWalls[wall[0]][wall[1]] = true
	
	for y in mapInfo.sizeY:
		var arrayY: Array[bool] = []
		for x in mapInfo.sizeX - 1:
			arrayY.append(false)
		verticalWalls.append(arrayY)
	for wall in mapInfo.verticalWallsPositions:
		verticalWalls[wall[0]][wall[1]] = true
	
	var positionsToCheck = [[mapInfo.objectsPositions[0][0] - 1, mapInfo.objectsPositions[0][1] - 1]]
	
	while (positionsToCheck.size() > 0):
		var thisPos: Array = positionsToCheck.pop_front()
		var thisPosX: int = thisPos[1]
		var thisPosY: int = thisPos[0]
		if thisPosY != 0 && !horizontalWalls[thisPosY - 1][thisPosX]:								#перевіряти верхню клітинку
			if !gameField[thisPosY - 1][thisPosX]:
				positionsToCheck.append([thisPosY - 1, thisPosX])
				gameField[thisPosY - 1][thisPosX] = true
		if thisPosY != mapInfo.sizeY - 1 && !horizontalWalls[thisPosY][thisPosX]:					#перевіряти нижню клітинку
			if !gameField[thisPosY + 1][thisPosX]:
				positionsToCheck.append([thisPosY + 1, thisPosX])
				gameField[thisPosY + 1][thisPosX] = true
		if thisPosX != 0 && !verticalWalls[thisPosY][thisPosX - 1]:									#перевіряти ліву клітинку
			if !gameField[thisPosY][thisPosX - 1]:
				positionsToCheck.append([thisPosY, thisPosX - 1])
				gameField[thisPosY][thisPosX - 1] = true
		if thisPosX != mapInfo.sizeX - 1 && !verticalWalls[thisPosY][thisPosX]:					#перевіряти праву клітинку
			if !gameField[thisPosY][thisPosX + 1]:
				positionsToCheck.append([thisPosY, thisPosX + 1])
				gameField[thisPosY][thisPosX + 1] = true


#func receivePlayerRecordings(actions: Array[ActionInfo]):
	#var new_tank = playerTank.duplicate()
	#new_tank.name = "Duplicate"
	#new_tank.get_node("TankController").set_script(preload("res://scripts/repeater_control/actionsRepeaterControl.gd"))
	#add_child(new_tank)
	#new_tank.modulate = Color(0,1,0,1)
	#new_tank.is_alive = true
	#new_tank.get_node("TankController").createTimers(actions)
	#activateReplays()					#TODO: make it launch by button
func createReplays(players: Array[PlayerGameInfoDto]):
	for player in players:
		for replay in player.replays:
			if !replay.isActive: continue
			var actions: Array = JSON.parse_string(replay.actions)
			playersInGame += 1
			createPlayerRecording(player, actions, player.username + str(replay.turnNumber))

func watchReplay() -> bool:
	endGameReal()
	if previousActions == []: return false
	prepareForGame()
	createPlayerRecording(thisPlayerInfo, previousActions, "PlayerRecording")
	thisPlayerTank.setTankDisabled(true)
	gameUI.setGameHintLabel("Watching your recordings...")
	return true

func removeMyReplay():
	thisPlayerTank.setTankDisabled(false)
	endGameReal()
	prepareForGame()
	gameUI.setGameHintLabel("Record your turn!")
	for n in _pathToPlayers.get_children():
		if n.name == "PlayerRecording":
			n.queue_free()

func createPlayerRecording(playerInfo: PlayerGameInfoDto, actions: Array, tankName: String):
	var new_tank = playerTank.duplicate()
	new_tank.name = tankName
	new_tank.inGamePlayerId = playerInfo.inGamePlayerId
	new_tank.modulate = Color.from_string(playerInfo.color, Color.WHITE)
	new_tank.get_node("TankController").set_script(load("res://scripts/repeater_control/actionsRepeaterControl.gd"))
	new_tank.position = Vector2(50 + thisPlayerStartingPosition[1] * 100, 50 + thisPlayerStartingPosition[0] * 100)
	new_tank.startingPosition = Vector2(50 + thisPlayerStartingPosition[1] * 100, 50 + thisPlayerStartingPosition[0] * 100)
	_pathToPlayers.add_child(new_tank)
	new_tank.get_node("TankController").createTimers(actions)

func submitReplay():
	if previousActions == []: 
		Logger.log_error("You did not created replay yet to submit it")
		return
	var replayRequest = SubmitReplayDto.new()
	replayRequest.gameId = thisGameId
	replayRequest.actions = JSON.stringify(previousActions)
	var resultGame: GameDTO = await webService.submitGameReplay(replayRequest)
	loadGame(resultGame)

func prepareForGame():
	gameState = Enums.GameState.PRE_GAME
	for n in _pathToObjects.get_children():
		if !n.is_in_group("Base"):
			n.reset()
	for n in _pathToPlayers.get_children():
		if n.is_in_group("Tank"):
			n.resetTank()
		if n.is_in_group("Bullet"):
			n.queue_free()

func tankDied(tank: PhysicsBody2D, bullet: PhysicsBody2D = null):
	if bullet != null:
		Logger.log(tank.name + " died by " + bullet.name)
	else: 
		Logger.log(tank.name + " died bc has no more actions")
	playersAlive -= 1
	if playersAlive == 0:
		endGameReal()
		artifactDelivered(-1)

func endGameReal():				#TODO: in most cases just resetting UI will be enough
	Global.gameUI._on_restart_replay_button_pressed()

func endGame():
	$TimerOfGameEnd.stop()
	#If its already post game -> just reset all objects
	if Enums.GameState.POST_GAME == gameState:
		prepareForGame()
		return
	gameState = Enums.GameState.POST_GAME
	for n in _pathToPlayers.get_children():
		if n.is_in_group("Tank") && n.tankState.is_alive:
			n.makeTankDead()
		if n.is_in_group("Bullet"):
			n.queue_free()

func cleanField():
	Logger.log("cleaning field")
	gameState = Enums.GameState.PRE_GAME
	thisPlayerInfo = null
	previousActions = []
	#gameUI.setDisabledForSubmitTurn(true)
	thisPlayerTank = null
	playersInGame = 0
	for n in _pathToPlayers.get_children():
		n.queue_free()
	for n in _pathToField.get_children():
		n.queue_free()
	for n in _pathToObjects.get_children():
		n.queue_free()

func _on_timer_of_game_end_timeout() -> void:
	endGameReal()
	artifactDelivered(-1)

func artifactDelivered(byInGamePlayerId: int):
	if !shouldCalculateScore: return
	
	var scores = ScoresDto.new()
	scores.gameId = thisGameId
	if byInGamePlayerId != -1:
		scores.scores[byInGamePlayerId] = 25
	
	var resultGame: GameDTO = await webService.endGameTurn(scores)
	loadGame(resultGame)

func reloadGame():
	endGame()
	var game: GameDTO = await webService.getFullGame(thisGameId)
	loadGame(game)











