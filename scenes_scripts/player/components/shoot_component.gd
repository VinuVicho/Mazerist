extends Node

var childNodes: Array = []
var bullet = preload("res://scenes/player/bullet/commonBullet.tscn")

func prepare():			#TODO: probably prepare this component for different situations
	childNodes = get_children()

func addModule():
	pass			#TODO: add shoot moifications here

func shoot(positionOfStart: Vector2, rotation):
	var weaponCol = get_parent().get_node("BulletCollision/WeaponCollision")
	weaponCol.disabled = true
	get_parent().get_node("WeaponCooldown").start()
	var created = bullet.instantiate()
	created.setVelocity(Vector2(0, -1).rotated(rotation))
	get_parent().get_parent().add_child(created)
	created.global_position = positionOfStart
	await get_tree().create_timer(0.3).timeout
	weaponCol.disabled = false
