extends Node2D

#TODO: make another walls (this has collisions, that is not used)
var wallForCreation = preload("res://scenes/field/wall.tscn").instantiate()
var circleSprite = preload("res://resources/circle_sprite.tscn").instantiate()
var squareSprite = preload("res://resources/square_sprite.tscn").instantiate()

var _pathToField: Node
var gameActive: bool = true

var player: Node2D
var currentPosX: int
var currentPosY: int
var mapSize: Vector2i
var walls: PackedInt32Array

var mainPositions: Dictionary = {}
enum MAIN_MENU_POSITION_TYPE {
	EXIT,
	MULTIPLAYER,
	SOLO,
	OPTIONS,
}

func _ready() -> void:
	_pathToField = $Field
	create_menu_maze()

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed(): 
		#if !event.is_echo():		#TODO: make with echo
		if event.is_action("UP"):
			if currentPosY != 1:
				if walls.find(2_000_000_000 + currentPosX * 1000 + currentPosY - 1) == -1:
					currentPosY = currentPosY - 1
					updatePlayerPosition()
			else: 
				triggerUserAction()
		if event.is_action("DOWN"):
			if currentPosY != mapSize.y:
				if walls.find(2_000_000_000 + currentPosX * 1000 + currentPosY) == -1:
					currentPosY = currentPosY + 1
					updatePlayerPosition()
			else: 
				triggerUserAction()
		if event.is_action("LEFT"):
			if currentPosX != 1:
				if walls.find(1_000_000_000 + currentPosX * 1000 + currentPosY - 1000) == -1:
					currentPosX = currentPosX - 1
					updatePlayerPosition()
			else: 
				triggerUserAction()
		if event.is_action("RIGHT"):
			if currentPosX != mapSize.x:
				if  walls.find(1_000_000_000 + currentPosX * 1000 + currentPosY) == -1:
					currentPosX = currentPosX + 1
					updatePlayerPosition()
			else: 
				triggerUserAction()
		if event.is_action("SUBMIT"): triggerUserAction()
func updatePlayerPosition(): player.position = Vector2i(currentPosX * 100 + 50, currentPosY * 100 + 50)
func triggerUserAction():
	var action = mainPositions.get(currentPosX * 1000 + currentPosY)
	if action != null: match action:
		MAIN_MENU_POSITION_TYPE.EXIT: exitGame()
		MAIN_MENU_POSITION_TYPE.MULTIPLAYER: _on_online_button_pressed()
		MAIN_MENU_POSITION_TYPE.SOLO: MyLogger.log_error("Not Implemented")		#TODO
		MAIN_MENU_POSITION_TYPE.OPTIONS: MyLogger.log_error("Not Implemented")	#TODO

func addMainMenuObjects(sizeX, sizeY) -> void:
	mainPositions.clear()
	addPlayer(1, 1)
	addExitButton(1, sizeY)
	addMultiplayerButton(sizeX, sizeY)

@warning_ignore("INTEGER_DIVISION")
func create_menu_maze() -> void:
	#TODO: make more custom fields (sizeX sizeY)
	var sizeX: int = 17
	var sizeY: int = 9
	
	mapSize = Vector2i(sizeX, sizeY)
	addMainMenuObjects(sizeX, sizeY)
	
	placeCamera(sizeX, sizeY)
	walls = MapGenerator.generateMap(sizeX, sizeY, randi_range(-1, sizeY/2))
	
	createSideWalls(sizeX, sizeY)
	for pos in mainPositions:
		var posX = pos / 1000
		var posY = pos % 1000
		if posX == 1: _pathToField.get_node("LeftWall" + str(posY)).queue_free()
		elif posX == sizeX: _pathToField.get_node("RightWall" + str(posY)).queue_free()
		if posY == 1: _pathToField.get_node("TopWall" + str(posX)).queue_free()
		elif posY == sizeY: _pathToField.get_node("BottomWall" + str(posX)).queue_free()
	for wallId in walls:
		var wall = wallForCreation.duplicate()
		_pathToField.add_child(wall)
		if wallId < 2_000_000_000:
			wallId = wallId - 1_000_000_000
			wall.name = "VerticalWall" + str(wallId)
			wall.set_rotation_degrees(90)
			wall.position = Vector2(100 + 100 * (wallId / 1000), 100 * (wallId % 1000) + 50)
		else:
			wallId = wallId - 2_000_000_000
			wall.name = "HorizontalWall" + str(wallId)
			wall.position = Vector2(50 + 100 * (wallId / 1000), 100 + (wallId % 1000) * 100)
func createSideWalls(sizeX: int, sizeY: int):
	for xId in range(1, sizeX + 1):		#horizontal side wall creation
		var wall = wallForCreation.duplicate()
		_pathToField.add_child(wall)
		wall.name = "TopWall" + str(xId)
		wall.position = Vector2(xId * 100 + 50, 100)
		
		wall = wallForCreation.duplicate()
		_pathToField.add_child(wall)
		wall.name = "BottomWall" + str(xId)
		wall.position = Vector2(xId * 100 + 50, 100 * sizeY + 100)
	for yId in range(1, sizeY + 1):		#vertical side wall creation
		var wall = wallForCreation.duplicate()
		wall.set_rotation_degrees(90)
		_pathToField.add_child(wall)
		wall.name = "LeftWall" + str(yId)
		wall.position = Vector2(100, 100 * yId + 50)
		
		wall = wallForCreation.duplicate()
		wall.set_rotation_degrees(90)
		_pathToField.add_child(wall)
		wall.name = "RightWall" + str(yId)
		wall.position = Vector2(sizeX * 100 + 100, 100 * yId + 50)
func placeCamera(sizeX: int, sizeY: int):
	var pixelsX: float = (sizeX + 2) * 100
	var pixelsY: float = (sizeY + 2) * 100
	var window_size = DisplayServer.screen_get_size()
	var scaleForX: float = window_size.x / pixelsX
	var scaleForY: float = window_size.y / pixelsY
	if scaleForX > scaleForY:
		$MenuCamera.zoom = Vector2(scaleForY, scaleForY)
	else:
		$MenuCamera.zoom = Vector2(scaleForX, scaleForX)
	$MenuCamera.position = Vector2((sizeX+2)*50, (sizeY+2)*50)
	$MenuCamera.enabled = true

#Adds player sprite at top left corner of map
func addPlayer(sizeX: int, sizeY: int):
	currentPosX = sizeX
	currentPosY = sizeY
	#TODO: make arrow or tank, not circle
	var circle = circleSprite.duplicate()
	circle.name = "MainMenuPlayer"
	$PlayerContainer/PathForMazeSolver/PathFollow2D.add_child(circle)
	player = circle
	updatePlayerPosition()
func addButtonToTheField(pos: Vector2i, bText: String):
	var newButton = Button.new()
	newButton.size = Vector2(100, 100)
	newButton.position = pos
	@warning_ignore("INTEGER_DIVISION")
	newButton.pressed.connect(changePositionAndTriggerAction(pos.x / 100, pos.y / 100))
	newButton.text = bText
	newButton.flat = true
	newButton.focus_mode = Control.FOCUS_NONE
	_pathToField.add_child(newButton)
func addExitButton(sizeX: int, sizeY: int):
	mainPositions[sizeX * 1000 + sizeY] = MAIN_MENU_POSITION_TYPE.EXIT
	addButtonToTheField(Vector2(sizeX * 100, sizeY * 100), "Exit")
func addMultiplayerButton(sizeX: int, sizeY: int) -> void:
	mainPositions[sizeX * 1000 + sizeY] = MAIN_MENU_POSITION_TYPE.MULTIPLAYER
	addButtonToTheField(Vector2(sizeX * 100, sizeY * 100), "Online")

func changePositionAndTriggerAction(moveToPosX: int, moveToPosY: int) -> Callable:
	return func (): 
		if $PlayerContainer/AnimationPlayer.is_playing():
			MyLogger.log_warning("Currently animation is playing, probably fix this later")					#TODO
			return
		var path = MapGenerator.findPath(currentPosX, currentPosY, moveToPosX, moveToPosY, mapSize.x, mapSize.y, walls)
		currentPosX = moveToPosX
		currentPosY = moveToPosY
		if (path.size() > 1):
			player.position = Vector2i(0, 0)
			#CREATE PATH
			var curve: Curve2D = $PlayerContainer/PathForMazeSolver.curve
			for pathPoint in path:
				var pathPointX: int = pathPoint / 1000
				var pathPointY: int = pathPoint % 1000
				curve.add_point(Vector2i(pathPointX * 100 + 50, pathPointY * 100 + 50))
			$PlayerContainer/AnimationPlayer.play("FollowPath")
		else: 
			updatePlayerPosition()
			triggerUserAction()
		
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	resetCurve()
	updatePlayerPosition()
	triggerUserAction()
func resetCurve():
	var curve: Curve2D = $PlayerContainer/PathForMazeSolver.get_curve()
	curve.clear_points()
	$PlayerContainer/PathForMazeSolver/PathFollow2D.position = Vector2(0, 0)

func _on_online_button_pressed() -> void:
	MyLogger.log("Executing multiplayer button")
	get_parent().get_parent()._on_multiplayer_button_pressed()
func exitGame() -> void:
	MyLogger.log("Executing exit game button")
	Global.interfaceService._on_exit_button_pressed()

func _on_visibility_changed() -> void:
	var currentlyOnGame: bool = visible and get_parent().visible
	if currentlyOnGame: 
		process_mode = Node.PROCESS_MODE_INHERIT
	else: 
		process_mode = Node.PROCESS_MODE_DISABLED
	$MenuCamera.enabled = currentlyOnGame
