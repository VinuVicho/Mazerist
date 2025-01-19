class_name Logger

static var logs: PackedStringArray = []

static func log(message: Variant) -> void:
	var logmsg = Time.get_time_string_from_system(true) + "| " + str(message)
	print_rich(logmsg)
	logs.append(logmsg)

static func get_logs() -> PackedStringArray:
	return logs 

static func log_error(message: String) -> void:
	Global.errorDisplayer.displayError(message)
	var logmsg = Time.get_time_string_from_system(true) + "| ERROR: " + message
	logs.append(logmsg)
	print_rich("[color=red]" + logmsg + "[/color]")

static func log_warning(message: Variant) -> void:
	var logmsg = Time.get_time_string_from_system(true) + "| WARNING: " + str(message)
	logs.append(logmsg)
	print_rich("[color=yellow]" + logmsg + "[/color]")

static func log_with_color(message, color: String = "ORANGE") -> void:
	var logmsg = Time.get_time_string_from_system(true) + "| " + color + ": " + str(message)
	logs.append(logmsg)
	print_rich("[color=" + color + "]" + logmsg + "[/color]")
