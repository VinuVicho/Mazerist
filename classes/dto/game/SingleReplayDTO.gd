class_name SingleReplayDto

var replayId: int
var gameId: int
var playerId: int
var turnNumber: int
var isActive: bool
var actions: String

func toJSON() -> Dictionary:
	return {
		"replayId": replayId, 
		"playerId": playerId, 
		"gameId": gameId, 
		"turnNumber": turnNumber, 
		"isActive": isActive, 
		"actions": actions,
	}

static func toObject(json: Dictionary) -> SingleReplayDto:
	var result: SingleReplayDto = SingleReplayDto.new()
	result.playerId = json["playerId"]
	result.gameId = json["gameId"]
	result.turnNumber = json["turnNumber"]
	result.isActive = json["isActive"]
	result.actions = json["actions"]
	
	return result

static func toListOfObjects(jsons: Array) -> Array[SingleReplayDto]:
	var result: Array[SingleReplayDto] = []
	for json in jsons:
		result.append(toObject(json))
	return result
func _to_string() -> String:
	return JSON.stringify(toJSON())

