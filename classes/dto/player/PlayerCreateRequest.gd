class_name PlayerCreateRequest

var login: String
var password: String
var username: String
var color: String

func _to_string() -> String:
	return JSON.stringify(toJSON())

func toJSON() -> Dictionary:
	return {
		"login": login, 
		"password": password, 
		"color": color, 
		"username": username
	}
