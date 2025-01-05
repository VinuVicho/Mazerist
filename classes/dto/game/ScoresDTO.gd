class_name ScoresDto

var gameId: int
var scores: Dictionary = {}

func toJSON() -> Dictionary:
	var result = {
		"gameId": gameId, 
		"scores": scores,
	}
	return result

static func toObject(json: Dictionary) -> ScoresDto:
	var result: ScoresDto = ScoresDto.new()
	result.gameId = json["gameId"]
	result.scores = json["scores"]
	return result

func _to_string() -> String:
	return JSON.stringify(toJSON())

