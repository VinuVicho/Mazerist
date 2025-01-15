class_name FieldRequest

var minSizeX: int = 3
var minSizeY: int = 3
var maxSizeX: int = 20
var maxSizeY: int = 20
#var amountOfPositions: int = 2		#TODO
var wallsPercentage: int = 70
var fieldSeed: int = 0
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
	return JSON.stringify(toJSON())

static func toObject(json: Dictionary) -> FieldRequest:
	
	var result := FieldRequest.new()
	
	result.minSizeX = json["minSizeX"]
	result.minSizeY = json["minSizeY"]
	result.maxSizeX = json["maxSizeX"]
	result.maxSizeY = json["maxSizeY"]
	result.playersNumber = json["playersNumber"]
	result.wallsPercentage = json["wallsPercentage"]
	result.fieldGenerationType = json["fieldGenerationType"]
	result.playersPositionType = json["playersPositionType"]
	
	var maybeSeed = json["fieldSeed"]
	if maybeSeed != null:
		result.fieldSeed = maybeSeed
	return result
