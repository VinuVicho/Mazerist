class_name MapReplay

var gameId: int
var players: Array[PlayerInfo]
var mapInfo: MapInfo = MapInfo.new()
var replays: Array[SingleReplay]
var gameTime: int = 10
var turn: int

func toJSON() -> Dictionary:
	var playersInfo = []
	for player in players:
		playersInfo.append(player.toJSON())
	var replayInfo = []
	for replay in replays:
		replayInfo.append(replay.toJSON())
	var dictWithInfo = {
		"gameId": gameId, 
		"players": playersInfo, 
		"mapInfo": mapInfo.toJSON(), 
		"replays": replayInfo,
		"gameTime": gameTime,
		"turn": turn,
	}
	return dictWithInfo
