class_name LobbyDTO

var lobbyId: int
var lobbyName: String
var lobbyOwnerId: int
var hasPassword: bool
var players: Array[PlayerDTO]
var lobbySettings: FieldRequest

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	var resultDictionary = {
		"lobbyId": lobbyId,
		"lobbyName": lobbyName,
		"lobbyOwnerId": lobbyOwnerId,
		"hasPassword": hasPassword,
	}
	
	var playersList: Array[Dictionary] = []
	for player in players:
		playersList.append(player.to_JSON())
	resultDictionary["players"] = playersList
	
	if lobbySettings != null:
		resultDictionary["lobbySettings"] = lobbySettings.toJSON()
		
	return resultDictionary

static func toObject(json: Dictionary) -> LobbyDTO:
	var result: LobbyDTO = LobbyDTO.new()
	result.lobbyId = json["lobbyId"]
	result.lobbyName = json["lobbyName"]
	result.lobbyOwnerId = json["lobbyOwnerId"]
	result.hasPassword = json["hasPassword"]
	
	result.players = []
	var playerJSONs = json["players"]
	for playerJSON in playerJSONs:
		result.players.append(PlayerDTO.toObject(playerJSON))
	
	var lobbySettingsJSON = json["lobbySettings"]
	if lobbySettingsJSON != null:
		result.lobbySettings = FieldRequest.toObject(json["lobbySettings"])
	
	return result

static func toListOfObjects(jsons: Array) -> Array[LobbyDTO]:
	var result: Array[LobbyDTO]
	for json in jsons:
		result.append(toObject(json))
	return result
