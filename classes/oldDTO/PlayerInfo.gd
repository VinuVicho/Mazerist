class_name PlayerInfo

var playerId: int
var color: String
var playerName: String

func _init(_playerId: int, _color: String, _playerName: String) -> void:
	playerId = _playerId
	color = _color
	playerName = _playerName

func toJSON():
	var dictWithInfo = {
		"playerId": playerId, 
		"color": color, 
		"playerName": playerName
	}
	return dictWithInfo
	
