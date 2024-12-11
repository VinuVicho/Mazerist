extends Control

var randomNumber = 1

#		%ExceptionDisplayer.displayError("test Error")
func displayError(message: String):
	Logger.log("Error: " + message)
	$PanelContainer/HBoxContainer/ErrorDisplayMessage.text = message
	visible = true
	$Timer.start()


func _on_timer_timeout() -> void:
	visible = false
