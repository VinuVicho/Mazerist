class_name SubmitReplayDto

var gameId: int
var actions: String

func toJSON() -> Dictionary:
	return {
		"gameId": gameId, 
		"actions": actions,
	}

static func toObject(json: Dictionary) -> SubmitReplayDto:
	var result: SubmitReplayDto = SubmitReplayDto.new()
	result.gameId = json["gameId"]
	result.actions = json["actions"]
	return result

static func toListOfObjects(jsons: Array) -> Array[SubmitReplayDto]:
	var result: Array[SubmitReplayDto] = []
	for json in jsons:
		result.append(toObject(json))
	return result
func _to_string() -> String:
	return JSON.stringify(toJSON())

