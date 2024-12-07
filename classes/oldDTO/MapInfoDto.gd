class_name MapInfoDto

var size: Vector2i
var mapType: String
var positions: PackedInt32Array = []

func toJSON():
	var dictWithInfo = {
		"size": size, 
		"mapType": mapType, 
		"positions": positions
	}
	return dictWithInfo
