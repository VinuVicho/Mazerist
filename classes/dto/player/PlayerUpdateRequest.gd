class_name PlayerUpdateRequest

var color: String

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	return {
		"color": color, 
	}
