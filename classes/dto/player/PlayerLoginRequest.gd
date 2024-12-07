class_name PlayerLoginRequest

var login: String
var password: String

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	return {
		"login": login, 
		"password": password,
	}
