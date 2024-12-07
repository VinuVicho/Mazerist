class_name FieldRequestForGen

var minSizeX: int = 3
var minSizeY: int = 3
var maxSizeX: int = 10
var maxSizeY: int = 10
#var amountOfPositions: int = 2		#TODO
var wallsPercentage: int = 70
var fieldSeed: int = 8084
var playersNumber: int = 3
var fieldGenerationType: int = 0
var playersPositionType: int = 0

func toJSON():
	var dictWithInfo = {
		"minSizeX": minSizeX, 
		"minSizeY": minSizeY, 
		"maxSizeX": maxSizeX, 
		"maxSizeY": maxSizeY, 
		"wallsPercentage": wallsPercentage, 
		"fieldSeed": fieldSeed, 
		"playersNumber": playersNumber, 
		"fieldGenerationType": fieldGenerationType, 
		"playersPositionType": playersPositionType, 
	}
	return dictWithInfo


func _to_string() -> String:
	return JSON.stringify({
		"minSizeX": minSizeX, 
		"minSizeY": minSizeY, 
		"maxSizeX": maxSizeX, 
		"maxSizeY": maxSizeY, 
		"wallsPercentage": wallsPercentage, 
		"fieldSeed": fieldSeed, 
		"playersNumber": playersNumber, 
		"fieldGenerationType": fieldGenerationType, 
		"playersPositionType": playersPositionType, 
	})
