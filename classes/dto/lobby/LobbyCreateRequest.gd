class_name LobbyRequest

var lobbyId: int
var lobbyName: String
var lobbyPassword: String
var fieldRequest: FieldRequest = FieldRequest.new()

var lobbyOwnerId: int

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	return {
		"lobbyId": lobbyId, 
		"lobbyName": lobbyName, 
		"lobbyPassword": lobbyPassword, 
		"lobbyOwnerId": lobbyOwnerId, 
		"fieldRequest": fieldRequest.toJSON(), 
	}
