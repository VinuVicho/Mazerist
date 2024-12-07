extends Node
class_name FieldController

"""
Тут я щось хотів робити із $SubViewPort -- карту окремо і гравцю це просто транслювати
Проте щось тут не працює, треба розбиратисб

Мабуть зробити просто об'єкт FieldContainer де будуть всі стінки, 
і його поки що в FieldController, а потім вже перенести в ViewPort 
"""

var playerTank = preload("res://scenes/player/tank.tscn").instantiate()
var wallForCreation = preload("res://scenes/field/wall.tscn").instantiate()
var circleSprite = preload("res://resources/circle_sprite.tscn").instantiate()
var replay_started = false
var game_started = false
@onready var _pathToField = $FieldContainerForNow
#@onready var _pathToField = $SubViewport/Field

var gameType = "capture"			#Typo of game played

func _ready():
	print('ready')
	createMainPlayer()
	test()
	$TimerToStart.start() 				#TODO: make after button

	


func receivePlayerRecordings(actions: Array[ActionInfo]):
	var new_tank = playerTank.duplicate()
	new_tank.name = "Duplicate"
	new_tank.get_node("TankController").set_script(preload("res://scenes_scripts/new_script.gd"))
	add_child(new_tank)
	new_tank.modulate = Color(0,1,0,1)
	new_tank.is_alive = true
	new_tank.get_node("TankController").createTimers(actions)
	activateReplays()					#TODO: make it launch by button

func activateReplays():
	print("replaysActivated")
	for tank in get_tree().get_nodes_in_group("Tank"):
		if tank.name == "Player": continue
		tank.makeTankAlive()
	for timer in get_tree().get_nodes_in_group("RepeaterTimer"):
		timer.start()

#region PrepareField
func prepareField(mapReplay: MapReplay):			#Викликати із Main для завантаження поля, реплеїв
	$EndGameTimer.wait_time = mapReplay.gameTime
	for n in _pathToField.get_children():
		if n.is_in_group('Wall') || n.is_in_group("testCircle1"):
			n.queue_free()
	makeFieldWalls(mapReplay.mapInfo)
	prepareObjects(mapReplay.mapInfo, mapReplay.playerDictionary)
	
	#for tank in get_tree().get_nodes_in_group("Tank"):							#Поки що ніц не робить
		#tank.prepareTank()

#region PrepareObjects
func prepareObjects(mapInfo: MapInfo, playersInfo: Dictionary):
	var objectsPostions: Array = mapInfo.objectsPositions
	for objPos in  objectsPostions:
		var objId: int = objPos[2]
		var newCircle = circleSprite.duplicate()
		_pathToField.add_child(newCircle)
		newCircle.position = Vector2(50 + objPos[1] * 100, 50 + objPos[0] * 100)
		newCircle.name = "circleSprite" + str(objId)
		var playerInfo = playersInfo.get(objId)
		newCircle.modulate = Color(playerInfo.color)
#endregion
#region Prepare Walls
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

#endregion

#endregion 

func createMainPlayer():
	var new_tank = playerTank.duplicate()
	new_tank.name = "Player"
	#print("Main player creation (FieldController.createMainPlayer)")
	#new_tank.get_node("TankController").set_script(preload("res://scenes_scripts/player/player_control/singlePlayerControl.gd")) #TODO
	_pathToField.add_child(new_tank)
	#print("Main player creation end (FieldController.createMainPlayer)")
	new_tank.modulate = Color(1,0,0,1)

func test():
	pass

func _on_timer_to_start_timeout():
	game_started = true
	print("gameStarted")
	_pathToField.get_node("Player").makeTankAlive()
	$EndGameTimer.start()

func _on_end_game_timer_timeout():
	print("GAME END")
	print("Print from Field class: " + Global.webService.print_something())

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("I"):
		var request = FieldRequestForGen.new()
		request.fieldSeed = 0
		var result: MapInfo = await Global.webService.send_map_request(request)
		if (result != null):
			print(result.toJSON())
			var fakeMapReplay = makeFakeMapReplay(result)
			prepareField(fakeMapReplay)
		else:
			print("null  responce")

func makeFakeMapReplay(mapInfo: MapInfo) -> MapReplay:
	var result = MapReplay.new()
	result.mapInfo = mapInfo
	var playerInfo0: PlayerInfo = PlayerInfo.new(0, "#56d333", "Player0")
	var playerInfo1: PlayerInfo = PlayerInfo.new(1, "#0000ff", "Player0")
	var playerInfo2: PlayerInfo = PlayerInfo.new(2, "#eb4034", "Player0")
	var playersInfoFake: Dictionary = {0: playerInfo0, 1: playerInfo1, 2:playerInfo2}
	result.playerDictionary = playersInfoFake
	return result
