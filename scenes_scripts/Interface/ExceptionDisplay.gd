class_name ErrorDisplayer extends CanvasLayer

var randomNumber = 1
static var isHighPriorityShown: bool = false 

func _ready() -> void:
	Global.errorDisplayer = self

#		%ExceptionDisplayer.displayError("test Error")
func displayError(message: String, isHighPriority: bool = false):
	if isHighPriority || !isHighPriorityShown:
		$PanelContainer/HBoxContainer/ErrorDisplayMessage.text = message
		visible = true
		$Timer.start()
		isHighPriorityShown = isHighPriority


func _on_timer_timeout() -> void:
	isHighPriorityShown = false
	visible = false
