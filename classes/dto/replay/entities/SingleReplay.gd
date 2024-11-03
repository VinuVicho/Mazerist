class_name SingleReplay

var replayId: int
var playerId: int
var actions: Array[ActionInfo]

func toJSON():
	var actionsInfo = []
	for action in actions:
		actionsInfo.append(action.to_string())
	var dictWithInfo = {
		"replayId": replayId, 
		"playerId": playerId, 
		"actions": actionsInfo
	}
	return dictWithInfo
