class_name FieldObject extends Area2D

var startingPos: Vector2
var forTeam: int = -1

func reset() -> void:
	position = startingPos
	visible = true
	set_deferred("monitorable", true)

func canIteract(interactWith: int) -> bool:
	return (forTeam == -1 or forTeam == interactWith)
