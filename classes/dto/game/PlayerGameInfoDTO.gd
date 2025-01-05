class_name PlayerGameInfoDto

var playerId: int

var inGamePlayerId: int
var score: int
var username: String
var color: String

var turnsCompleted: int
var replays: Array[SingleReplayDto]

func toJSON() -> Dictionary:
	var result = {
		"playerId": playerId, 
		"score": score,
		"turnsCompleted": turnsCompleted,
		"username": username,
		"color": color,
		"inGamePlayerId": inGamePlayerId,
	}
	
	## Array of obj
	var replaysList: Array[Dictionary] = []
	for replay in replays:
		replaysList.append(replay.to_JSON())
	result["replays"] = replaysList
	
	return result

static func toObject(json: Dictionary) -> PlayerGameInfoDto:
	var result: PlayerGameInfoDto = PlayerGameInfoDto.new()
	
	result.playerId = json["playerId"]
	result.username = json["username"]
	result.score = json["score"]
	result.turnsCompleted = json["turnsCompleted"]
	result.color = json["color"]
	result.inGamePlayerId = json["inGamePlayerId"]
	
	## Array of obj
	result.replays = []
	var replayJSONs = json["replays"]
	for replayJSON in replayJSONs:
		result.replays.append(SingleReplayDto.toObject(replayJSON))
	
	return result

## Used when retrieve array of objects as responce in webService
static func toListOfObjects(jsons: Array) -> Array[PlayerGameInfoDto]:
	var result: Array[PlayerGameInfoDto] = []
	for json in jsons:
		result.append(toObject(json))
	return result
func _to_string() -> String:
	return JSON.stringify(toJSON())

