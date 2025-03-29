class_name MainScene extends Node

"""
Після цього методу всі дочірні класи можуть брати глобальні зміни
(Спочатку ініціалізуються _ready дочірніх, а потім вже цей)
"""

func _init() -> void:
	Global.mainScene = self

func _ready() -> void:
	Global.interfaceService.changeGameState(Enums.ProgramState.MAIN_MENU)

