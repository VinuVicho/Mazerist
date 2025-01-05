class_name ErrorDisplayer extends CanvasLayer

var randomNumber = 1

func _ready() -> void:
	Global.errorDisplayer = self

#		%ExceptionDisplayer.displayError("test Error")
func displayError(message: String):
	$PanelContainer/HBoxContainer/ErrorDisplayMessage.text = message
	visible = true
	$Timer.start()


func _on_timer_timeout() -> void:
	visible = false
