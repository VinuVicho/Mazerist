class_name WebService
extends Node

func send_map_request(request: FieldRequestForGen) -> MapInfo:
	return await $MapRequestHTTP.map_request_send(request)

static func print_something() -> String:
	return "WebService print"

