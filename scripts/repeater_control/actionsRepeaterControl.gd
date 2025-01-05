extends Node

var newTimer: Timer = load("res://scenes/repeater/timerForRepeater.tscn").instantiate()
var tank
var tankState: TankState


var startingActions: Array[Callable] = []
var actionId := -1

func _ready():
	tank = get_parent()
	tankState = get_parent().tankState

## Action should be:
## [actionNumber, ActionType, posX * 1000, posY * 1000, rotation * 100, time]
func createTimers(actions: Array):
	for a in actions:
		var actionType: Enums.ActionType = Enums.ActionType.values()[a[1]]		# TODO: find normal way to do so
		if Enums.ActionType.TANK_SPAWNED == actionType:
			tank.startingPosition = Vector2(a[2]/1000, a[3]/1000)
			continue
		var actionToDo: Callable
		match actionType:
			Enums.ActionType.MOVE_FORWARD:
				actionToDo = updateMovingAction(1, Vector2(float(a[2])/1000, float(a[3])/1000))
			Enums.ActionType.MOVE_BACKWARDS:
				actionToDo = (updateMovingAction(-1, Vector2(float(a[2])/1000, float(a[3])/1000)))
			Enums.ActionType.TURN_LEFT:
				actionToDo = (updateRotatingAction(-1, Vector2(float(a[2])/1000, float(a[3])/1000), float(a[4])/100))
			Enums.ActionType.TURN_RIGHT:
				actionToDo = (updateRotatingAction(1, Vector2(float(a[2])/1000, float(a[3])/1000), float(a[4])/100))
			Enums.ActionType.STOP_ROTATING:
				actionToDo = (updateRotatingAction(0, Vector2(float(a[2])/1000, float(a[3])/1000), float(a[4])/100))
			Enums.ActionType.STOP_MOVING:
				actionToDo = (updateMovingAction(0, Vector2(float(a[2])/1000, float(a[3])/1000)))
			Enums.ActionType.TANK_DIED:
				actionToDo = (func(): 
					if (tankState.is_alive):
						actionId = -1
						Global.gameService.tankDied(tank)
						#tankState.movingActionPressed = 0
						#tankState.rotatingActionPressed = 0
				)
			Enums.ActionType.SHOOT:
				actionToDo = (shootAction(Vector2(float(a[2])/1000, float(a[3])/1000), float(a[4])/100))
			_: Logger.log_error("Wrong action type: " + str(a[1]))
		var time := float(a[5])/1000
		if time == 0:
			startingActions.append(actionToDo)
			continue
		var timer = newTimer.duplicate(3)
		timer.name = "Timer" + str(a[0])
		timer.wait_time = time
		timer.timeout.connect(actionToDo)
		add_child(timer)
func updateMovingAction(newValue: int, position: Vector2):
	return func():
		if (tankState.is_alive):
			tank.position = position
		tankState.movingActionPressed = newValue
		actionId += 1
func updateRotatingAction(newValue: int, position: Vector2, rotation: float):
	return func():
		if (tankState.is_alive):
			tank.position = position
			tank.rotation_degrees = rotation
		actionId += 1
		tankState.rotatingActionPressed = newValue
func shootAction(position: Vector2, rotation: float):
	return func():
		if (tankState.is_alive):
			tank.position = position
			tank.rotation_degrees = rotation
		actionId += 1
		tank.shoot()

func startControl():
	for a in startingActions:
		a.call()
	for n in get_children():
		n.start()

func recordAction(_actionType): pass
