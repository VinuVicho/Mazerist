class_name PlayerDTO

var playerId: int
var username: String
var color: String
var isReady: bool
var isSpectator: bool
var lobbyId: int

func _to_string() -> String:
	return JSON.stringify(to_JSON())

func to_JSON() -> Dictionary:
	var dict := {
		"playerId": playerId, 
		"color": color, 
		"username": username,
	}
	if lobbyId != 0:
		dict.merge({
			"isReady": isReady,
			"isSpectator": isSpectator,
			"lobbyId": lobbyId,
		})
	return dict

static func toObject(json: Dictionary) -> PlayerDTO:
	var result: PlayerDTO = PlayerDTO.new()
	result.playerId = json["playerId"]
	result.username = json["username"]
	result.color = json["color"]
	
	result.isReady = json["isReady"]
	result.isSpectator = json["isSpectator"]
	result.lobbyId = json["lobbyId"]
	
	return result

static func toListOfObjects(jsons: Array) -> Array[PlayerDTO]:
	var result: Array[PlayerDTO] = []
	for json in jsons:
		result.append(toObject(json))
	return result
