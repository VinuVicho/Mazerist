class_name MyObject

var playerId: int
var username: String

func _to_string() -> String:
	return JSON.stringify({
		"playerId": playerId, 
		"username": username,
	})

static func toObject(json: Dictionary) -> MyObject:
	var result: MyObject = MyObject.new()
	
	result.playerId = json["playerId"]
	result.username = json["username"]
	
	return result
