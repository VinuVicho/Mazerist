class_name MapInfo

var fieldId: int
var sizeX: int
var sizeY: int

#Всередині буде PackedByteArray
var verticalWallsPositions: Array = []
var horizontalWallsPositions: Array = []
var objectsPositions: Array = [] 				#array, to sav obj and their Vector2i

#Властивості поля
var fieldGenerationType: int = 0
var playersPositionType: int = 0
var gameType: int = 0			#TODO
var wallsPercentage: int = 0
var fieldSeed: int = 0



func fillObjects() -> void:
	sizeY = 10
	sizeX = 10
	var w1: PackedByteArray = [3, 3]
	var w2: PackedByteArray = [3, 4]
	var w3: PackedByteArray = [1, 2]
	verticalWallsPositions.append_array([w1, w2, w3])
	w1 = [5, 6]
	w2 = [5, 7]
	w3 = [7, 7]
	horizontalWallsPositions.append_array([w1, w2, w3])
	w1 = [1, 1]
	w2 = [9, 9]
	objectsPositions.append_array([w1, w2])

func toJSON() -> Dictionary:
	var dictWithInfo:Dictionary = {
		"fieldId": fieldId,
		"sizeX": sizeX, 
		"sizeY": sizeY, 
		
		"horizontalWallsPositions": horizontalWallsPositions, 
		"verticalWallsPositions": verticalWallsPositions, 
		"objectsPositions": objectsPositions,
		
		"wallsPercentage": wallsPercentage,
		"fieldSeed": fieldSeed,
		"gameType": gameType,
		"fieldGenerationType": fieldGenerationType,
		"playersPositionType": playersPositionType,
	}
	return dictWithInfo

static func toObject(json: Dictionary) -> MapInfo:
	var result: MapInfo = MapInfo.new()
	result.fieldId = json["fieldId"]
	result.sizeX = json["sizeX"]
	result.sizeY = json["sizeY"]
	
	result.horizontalWallsPositions = json["horizontalWallsPositions"]
	result.verticalWallsPositions = json["verticalWallsPositions"]
	result.objectsPositions = json["objectsPositions"]
	
	result.wallsPercentage = json["wallsPercentage"]
	result.fieldGenerationType = json["fieldGenerationType"]
	result.gameType = json["gameType"]
	result.playersPositionType = json["playersPositionType"]
	result.fieldSeed = json["fieldSeed"]
	return result
