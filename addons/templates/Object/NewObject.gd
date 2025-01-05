class_name _CLASS_

var playerId: int
var username: String
var verticalWallsPositions: Array = []		# Basic types inside
#var players: Array[PlayerDTO]
#var lobbySettings: FieldRequest

func toJSON() -> Dictionary:
	var result = {
		"playerId": playerId, 
		"username": username,
		"verticalWallsPositions": verticalWallsPositions, 
	}
	
	## Array of obj
	#var playersList: Array[Dictionary] = []
	#for player in players:
		#playersList.append(player.to_JSON())
	#result["players"] = playersList
	
	## Nullable object
	#if lobbySettings != null:
		#result["lobbySettings"] = lobbySettings.toJSON()
	
	return result

static func toObject(json: Dictionary) -> _CLASS_:
	var result: _CLASS_ = _CLASS_.new()
	result.playerId = json["playerId"]
	result.username = json["username"]
	result.verticalWallsPositions = json["verticalWallsPositions"]
	
	## Array of obj
	#result.players = []
	#var playerJSONs = json["players"]
	#for playerJSON in playerJSONs:
		#result.players.append(PlayerDTO.toObject(playerJSON))
	
	## Nullable object
	#var lobbySettingsJSON = json["lobbySettings"]
	#if lobbySettingsJSON != null:
		#result.lobbySettings = FieldRequest.toObject(json["lobbySettings"])
	
	return result

## Used when retrieve array of objects as responce in webService
static func toListOfObjects(jsons: Array) -> Array[_CLASS_]:
	var result: Array[_CLASS_] = []
	for json in jsons:
		result.append(toObject(json))
	return result
func _to_string() -> String:
	return JSON.stringify(toJSON())
