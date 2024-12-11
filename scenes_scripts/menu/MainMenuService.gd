extends Control

func _ready() -> void:
	#TODO: prepare main screen
	$MainMenu.visible = true
	$MultiplayerMenu.visible = false
	$LoginMenu.visible = false
	

func _on_login_back_button_pressed() -> void:
	$LoginMenu.visible = false
	$MainMenu.visible = true


func _on_multiplayer_button_pressed() -> void:
	#TODO: check for saved creds, if there is -> try login (probably even on game launch)
	$MainMenu.visible = false
	$LoginMenu.visible = false
	if Global.webService.authentinticated:
		$MultiplayerMenu.visible = true
		return
	$LoginMenu.visible = true



func _on_back_to_main_menu_pressed() -> void:
	$MultiplayerMenu.visible = false
	$MainMenu.visible = true
	pass # Replace with function body.
