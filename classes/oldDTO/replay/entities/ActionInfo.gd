class_name ActionInfo

var actionId: int
var time: float
var action: int																	#Its enum
var position: Vector2
var rotation: float

func _init(_actionId, _time, _action, _position, _rotation):
	actionId = _actionId
	time = _time
	action = _action
	position = _position
	rotation = _rotation

func toJSON():
	var dictWithInfo = {
		"actionId": actionId, 
		"time": time, 
		"action": action, 
		"position": position, 
		"rotation": rotation
	}
	return dictWithInfo

static func toString(actions: Array[ActionInfo]) -> String:
	var result: Array = []
	for action in actions:
		result.append(action.toJSON())
	return str(result)
