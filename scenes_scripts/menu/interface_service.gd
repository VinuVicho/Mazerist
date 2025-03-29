class_name InterfaceService extends Control

func _init() -> void:
	Global.interfaceService = self

func _ready() -> void:
	$MainMenuService.visible = true


func _on_exit_button_pressed() -> void:
	get_tree().quit() 

func changeGameState(state: Enums.ProgramState):
	$MainMenuService.visible = state == Enums.ProgramState.MAIN_MENU
	$GameUI.visible = state == Enums.ProgramState.GAME

func exit_multiplayer() -> void:
	$MainMenuService._on_back_to_main_menu_pressed()
