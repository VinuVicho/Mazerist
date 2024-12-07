class_name MapReplayDto

var gameId: int
var players: Array[PlayerInfo]
var mapInfoDto: MapInfoDto = MapInfoDto.new()
var replays: Array[SingleReplay]
var gameTime: int

func toJSON():
	var playersInfo = []
	for player in players:
		playersInfo.append(player.toJSON())
	var replayInfo = []
	for replay in replays:
		replayInfo.append(replay.toJSON())
	var dictWithInfo = {
		"gameId": gameId, 
		"players": playersInfo, 
		"mapInfoDto": mapInfoDto.toJSON(), 
		"replays": replayInfo,
		"gameTime": gameTime,
	}
	return dictWithInfo
