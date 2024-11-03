extends Node

const moveBackwardsRatio = 0.5			#TODO: get this from parent node, also change in repeat code

var endGameTimer
var tank
var actionsArray: Array[ActionInfo] = []
var movingActionPressed: int = 0
var rotatingActionPressed: int = 0
var actionId := -1

func _ready():
	tank = get_parent()
	var _fieldController = get_parent().get_parent().get_parent()				#TODO: make it via GlobalScript, tank spawns in $PathToField
	endGameTimer = _fieldController.get_node("EndGameTimer")
	tankSpawned()

func _process(_delta):
	if (actionId == -1):							#TODO: make set_process(false) to disable any process here
		return
	
	var move = 0
	if Input.is_action_pressed("MoveForward"):
		move += 1
	if Input.is_action_pressed("MoveBack"):
		move -= 1
	if (move != 0):
		#--------------------------------------------------Record movement
		if (move == 1 and movingActionPressed != 1):
			recordAction(ActionsType.MOVE_FORWARD)
			movingActionPressed = 1
			tank.movingActionPressed = 1
		if (move == -1 and movingActionPressed != -1):
			recordAction(ActionsType.MOVE_BACKWARDS)
			movingActionPressed = -1
			tank.movingActionPressed = -1
	else: if (movingActionPressed != 0):
		recordAction(ActionsType.STOP_MOVING)
		movingActionPressed = 0
		tank.movingActionPressed = 0
	
	move = 0
	if Input.is_action_pressed("TurnRight"):
		move += 1
	if Input.is_action_pressed("TurnLeft"):
		move -= 1
	if (move != 0):
		#Record rotation
		if (move == -1 and rotatingActionPressed != -1):
			recordAction(ActionsType.TURN_LEFT)
			rotatingActionPressed = -1
			tank.rotatingActionPressed = -1
		if (move == 1 and rotatingActionPressed != 1):
			recordAction(ActionsType.TURN_RIGHT)
			rotatingActionPressed = 1
			tank.rotatingActionPressed = 1
	else: if (rotatingActionPressed != 0):
		recordAction(ActionsType.STOP_ROTATING)
		rotatingActionPressed = 0
		tank.rotatingActionPressed = 0
	
	if Input.is_action_pressed("R"):
		recordAction(ActionsType.SHOOT)
		tank.skillActionPressed = 1

func recordAction(action: int):
	actionId += 1
	actionsArray.append(ActionInfo.new(actionId, \
			100 - endGameTimer.time_left #Make sure timer is fine				\
			, action, tank.position, tank.rotation))

func addDeathRecord() -> Array[ActionInfo]:
	actionId += 1
	actionsArray.append(ActionInfo.new(actionId, endGameTimer.time_left, ActionsType.TANK_DIED, tank.position, tank.rotation))
	actionId = -1
	return actionsArray

func tankSpawned() :
	recordAction(ActionsType.TANK_SPAWNED)
