class_name InterfaceService extends Control


func _ready() -> void:
	$MainMenuService.visible = true


func _on_exit_button_pressed() -> void:
	print("Exit game.... and windows")
