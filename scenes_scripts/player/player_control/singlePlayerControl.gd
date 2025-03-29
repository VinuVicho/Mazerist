extends Node

const moveBackwardsRatio = 0.5			#TODO: get this from parent node, also change in repeat code

var endGameTimer: Timer
#var actionsArray: Array[ActionInfo] = []
var actionId := -1

var tankState: TankState

func _ready():
	endGameTimer = Global.gameService.getGameTimer()
	tankState = get_parent().tankState

func _process(_delta):				#in tank script set_process(false) to disable any process here
	if (actionId == -1):
		return
	
	var move = 0
	if Input.is_action_pressed("UP"):
		move += 1
	if Input.is_action_pressed("DOWN"):
		move -= 1
	if (move != 0):
		#--------------------------------------------------Record movement
		if (move == 1 and tankState.movingActionPressed != 1):
			recordAction(Enums.ActionType.MOVE_FORWARD)
			tankState.movingActionPressed = 1
		if (move == -1 and tankState.movingActionPressed != -1):
			recordAction(Enums.ActionType.MOVE_BACKWARDS)
			tankState.movingActionPressed = -1
	else: if (tankState.movingActionPressed != 0):
		recordAction(Enums.ActionType.STOP_MOVING)
		tankState.movingActionPressed = 0
	
	move = 0
	if Input.is_action_pressed("RIGHT"):
		move += 1
	if Input.is_action_pressed("LEFT"):
		move -= 1
	if (move != 0):
		#Record rotation
		if (move == -1 and tankState.rotatingActionPressed != -1):
			recordAction(Enums.ActionType.TURN_LEFT)
			tankState.rotatingActionPressed = -1
		if (move == 1 and tankState.rotatingActionPressed != 1):
			recordAction(Enums.ActionType.TURN_RIGHT)
			tankState.rotatingActionPressed = 1
	else: if (tankState.rotatingActionPressed != 0):
		recordAction(Enums.ActionType.STOP_ROTATING)
		tankState.rotatingActionPressed = 0
	
	if Input.is_action_pressed("R"):
		if !tankState.shootActionPressed:
			tankState.shootActionPressed = true
	elif tankState.shootActionPressed:
		tankState.shootActionPressed = false

func recordAction(action: int):
	actionId += 1
	tankState.actions.append([actionId, action, roundi(tankState.tankNode.position.x * 1000), roundi(tankState.tankNode.position.y * 1000), roundi(tankState.tankNode.rotation_degrees * 100), roundi((endGameTimer.wait_time - endGameTimer.time_left) * 1000)])
	if action == Enums.ActionType.TANK_DIED:
		Logger.log_with_color("Actions recorded in singlePlayerControl: " + JSON.stringify(tankState.actions), "DARK_ORANGE")
		Global.gameService.previousActions = tankState.actions
		#Global.gameUI.setDisabledForSubmitTurn(false)							#TODO: probably this
func addActionRecord(action: int):
	recordAction(action)

func startControl():
	actionId = -1
	recordAction(Enums.ActionType.TANK_SPAWNED)

