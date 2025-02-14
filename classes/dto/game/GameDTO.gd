class_name GameDTO

var gameId: int
var fieldId: int
var gameCreatorId: int
var gameFinished: bool
var gameTurn: int

var field: MapInfo
var players: Array[PlayerGameInfoDto]		#TODO: change for GamePlayerDTO

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	var resultDictionary = {
		"gameId": gameId,
		"gameTurn": gameTurn,
		"fieldId": fieldId,
		"gameFinished": gameFinished,
		"gameCreatorId": gameCreatorId,
	}
	
	var playersList: Array[Dictionary] = []
	for player in players:
		playersList.append(player.to_JSON())
	resultDictionary["players"] = playersList
	
	resultDictionary["field"] = field.toJSON()
	
	#if lobbySettings != null:
		#resultDictionary["lobbySettings"] = lobbySettings.toJSON()
		
	return resultDictionary

static func toObject(json: Dictionary) -> GameDTO:
	var result: GameDTO = GameDTO.new()
	result.gameId = json["gameId"]
	result.fieldId = json["fieldId"]
	result.gameCreatorId = json["gameCreatorId"]
	result.gameFinished = json["gameFinished"]
	result.gameTurn = json["gameTurn"]
	
	result.players = []
	var playerJSONs = json["players"]
	for playerJSON in playerJSONs:
		result.players.append(PlayerGameInfoDto.toObject(playerJSON))
	
	var maybeField = json["field"]
	if maybeField != null:
		result.field = MapInfo.toObject(json["field"])
	
	return result

static func toListOfObjects(jsons: Array) -> Array[GameDTO]:
	var result: Array[GameDTO] = []
	for json in jsons:
		result.append(toObject(json))
	return result
