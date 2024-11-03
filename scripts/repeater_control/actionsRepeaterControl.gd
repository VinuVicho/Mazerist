extends Node

const moveBackwardsRatio = 0.5			#TODO: get this from parent node, also change in player code

var tank

var actionId := -1

func _ready():
	tank = get_parent()

func createTimers(actions: Array[ActionInfo]):
	var timer = load("res://scenes/repeater/timerForRepeater.tscn").instantiate()
	timer.name = "Timer"
	add_child(timer)
	for actionInfo in actions:
		timer = $Timer.duplicate(3)
		timer.name = "Timer" + str(actionInfo.actionId)
		add_child(timer)
		timer.wait_time = actionInfo.time
		match actionInfo.action:
			ActionsType.MOVE_FORWARD:
				timer.timeout.connect(updateMovingAction(1, actionInfo.position))
			ActionsType.MOVE_BACKWARDS:
				timer.timeout.connect(updateMovingAction(-1, actionInfo.position))
			ActionsType.TURN_LEFT:
				timer.timeout.connect(updateRotatingAction(-1, actionInfo.position, actionInfo.rotation))
			ActionsType.TURN_RIGHT:
				timer.timeout.connect(updateRotatingAction(1, actionInfo.position, actionInfo.rotation))
			ActionsType.STOP_ROTATING:
				timer.timeout.connect(updateRotatingAction(0, actionInfo.position, actionInfo.rotation))
			ActionsType.STOP_MOVING:
				timer.timeout.connect(updateMovingAction(0, actionInfo.position))
			ActionsType.TANK_DIED:					#TODO: doesnt work (prob feature)
				timer.timeout.connect(func(): 
					if (tank.is_alive):
						actionId = -1
						tank.movingActionPressed = 0
						tank.rotatingActionPressed = 0
						tank.is_alive = false
				)
			ActionsType.TANK_SPAWNED:
				timer.timeout.connect(func(): 
					if (tank.is_alive):
						actionId = 0
						tank.position = actionInfo.position
						tank.rotation = actionInfo.rotation
				)
func updateMovingAction(newValue: int, position: Vector2):
	return func():
		if (tank.is_alive):
			actionId += 1
			tank.movingActionPressed = newValue
			tank.position = position
func updateRotatingAction(newValue: int, position: Vector2, rotation: float):
	return func():
		if (tank.is_alive):
			actionId += 1
			tank.rotatingActionPressed = newValue
			tank.position = position
			tank.rotation = rotation
