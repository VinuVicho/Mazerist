class_name GameWithStatusAction

var gameId: int
var gameCreatorId: int
var gameFinished: bool
var gameTurn: int
var statusAction: int

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	var resultDictionary = {
		"gameTurn": gameTurn,
		"gameFinished": gameFinished,
		"gameCreatorId": gameCreatorId,
		"gameId": gameId,
		"statusAction": statusAction,
	}
	return resultDictionary

static func toObject(json: Dictionary) -> GameWithStatusAction:
	var result: GameWithStatusAction = GameWithStatusAction.new()
	result.gameId = json["gameId"]
	result.gameCreatorId = json["gameCreatorId"]
	result.gameFinished = json["gameFinished"]
	result.gameTurn = json["gameTurn"]
	result.statusAction = json["statusAction"]
	return result

static func toListOfObjects(jsons: Array) -> Array[GameWithStatusAction]:
	var result: Array[GameWithStatusAction] = []
	for json in jsons:
		result.append(toObject(json))
	return result
