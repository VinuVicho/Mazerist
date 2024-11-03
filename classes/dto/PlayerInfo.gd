class_name PlayerInfo

var playerId: int
var color: String
var playerName: String

func toJSON():
	var dictWithInfo = {
		"playerId": playerId, 
		"color": color, 
		"playerName": playerName
	}
	return dictWithInfo
	
