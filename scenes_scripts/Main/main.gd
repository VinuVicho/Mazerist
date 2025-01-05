class_name MainScene extends Node

"""
Після цього методу всі дочірні класи можуть брати глобальні зміни
(Спочатку ініціалізуються _ready дочірніх, а потім вже цей)
"""

func _init() -> void:
	Global.mainScene = self

func _ready() -> void:
	Global.interfaceService.changeGameState(Enums.ProgramState.MAIN_MENU)

#func setCameraScale(sizeX: int, sizeY: int):
	#var pixelsX: float = (sizeX + 2) * 100
	#var pixelsY: float = (sizeY + 2) * 100
	#var window_size = get_viewport()
	#var scaleForX: float = get_viewport().size.x / pixelsX
	#var scaleForY: float = get_viewport().size.y / pixelsY
	#if scaleForX > scaleForY:
		#$MainCamera.zoom = Vector2(scaleForY, scaleForY)
	#else:
		#$MainCamera.zoom = Vector2(scaleForX, scaleForX)
	#
