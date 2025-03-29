extends Node

var field := PackedInt32Array()				#combine verified verticalWalls and horizontalWalls
# +- Up to 2_100_000_000 (explanation below)
# 0_000_xxx_yyy
# 0_1zz_xxx_yyy players positions, zz = playerId
# 1_000_xxx_yyy vertical wall positions - (max = size x - 1)
# 2_000_xxx_yyy horizontal wall positions | (max = field size y - 1)
var mapInfo : MapInfo
var positions := PackedInt32Array()
var request : FieldRequestForGen
var already_generating = false;

var verticalWalls: PackedInt32Array
var horizontalWalls: PackedInt32Array
var fieldWalls: PackedInt32Array


func _ready():
	request = FieldRequestForGen.new()
	request.maxY = 5
	request.minY = 5
	request.maxX = 3
	request.minX = 3
	var createdMap = generateDefaultField(request)
	print("Field info:")
	print(createdMap.toJSON())


func generateDefaultField(newRequest: FieldRequestForGen) -> MapInfo:			#Square, +-0_000_xxx_yyy, - = horizontal?
	already_generating = true
	request = newRequest
	validateInputRequest()
	mapInfo = MapInfo.new()
	
	calculateSize()
	for i in range(1, request.amountOfPositions + 1):
		createRandomPosition(100_000_000 + 1_000_000 * i, positions)
		print(positions)
	
	createDefaultMapWalls(shuffleInt32Array(createWalls()))
	
	
	
	
	already_generating = false
	return mapInfo

#func _process(delta): 
	#if (already_generating == false) :
		#already_generating = true;
		#createWalls();


func createDefaultMapWalls(walls: PackedInt32Array) -> void:
	walls.resize(walls.size() * request.wallsPercentage / 100)
	for wall in walls:
		
		pass
	pass
func createWalls() -> PackedInt32Array:
	var resultWalls: PackedInt32Array = []
	for x in range(1000, (mapInfo.size.x + 1) * 1000, 1000):
		for y in range(1, mapInfo.size.y):
			resultWalls.append(x + y + 2_000_000_000)
	for x in range(1000, mapInfo.size.x * 1000, 1000):
		for y in range(1, mapInfo.size.y + 1):
			resultWalls.append(x + y + 1_000_000_000)
	return resultWalls

func shuffleInt32Array(array) -> PackedInt32Array: 
	var array_to_shuffle = Array(array)
	array_to_shuffle.shuffle()
	return PackedInt32Array(array_to_shuffle)

func testVector() -> void:	#bad
	var vWallsVec: Array[Vector2i] = []
	var time_start = Time.get_unix_time_from_system()
	for x in range(1, 1_000):
		for y in range(1, 1_000):
			vWallsVec.append(Vector2i(x, y))
	for x in range(1, 1000):
		vWallsVec.find(Vector2i(randi_range(1, 1_000), randi_range(1, 1_000)))
	print(Time.get_unix_time_from_system() - time_start)
func testInt() -> void:		#good
	var vWallsInt:= PackedInt32Array()
	var time_start = Time.get_unix_time_from_system()
	for x in range(1000, 1_000_000, 1000):
		for y in range(1, 1_000):
			vWallsInt.append(x + y)
	for x in range(1, 1000):
		vWallsInt.find(randi_range(1, 1_000) * 1000 + randi_range(1, 1_000))
	print(Time.get_unix_time_from_system() - time_start)
func testArrayInt() -> void:
	var vWallsInt: Array[int] = []
	var time_start = Time.get_unix_time_from_system()
	for x in range(1, 1_000):
		for y in range(1, 1_000):
			vWallsInt.append(x + y)
	for x in range(1, 1000):
		vWallsInt.find(randi_range(1, 1_000) * 1000 + randi_range(1, 1_000))
	print(Time.get_unix_time_from_system() - time_start)

func createRandomPosition(addition: int, where) -> void:
	var pos = randi_range(1, mapInfo.size.y) + (randi_range(1, mapInfo.size.x) * 1000) + addition
	if where.has(pos):
		createRandomPosition(addition, where)
	else: 
		where.append(pos)
func calculateSize() -> void:
	var a = randi_range(request.minX, request.maxX)
	var b = randi_range(request.minY, request.maxY)
	if (b > a):
		mapInfo.size = Vector2i(a, b)
	else:
		mapInfo.size = Vector2i(b, a)
	#Validation
	if (request.amountOfPositions > a*b): calculateSize()

static func validateInputRequest() -> void:
	pass
