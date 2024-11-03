extends PhysicsBody2D

var tankId = -1				#TODO: set this value

@export var speed: float = 200;
@export var moveBackwardsRatio: float = 0.5;
@export var health: int = 1;
@export var rotation_speed: float = 2
@export var amount_of_bullets = 3

var is_alive := false
var current_speed = speed
var actions: Array

#For actions
var movingActionPressed: int = 0
var rotatingActionPressed: int = 0
var skillActionPressed: int = 0						#TODO: make skillActions enum

func _physics_process(delta):
	if (!is_alive):
		return
	#-------------------------------Move
	if (movingActionPressed != 0):			#TODO: save moving action pressed as moveBackwardsRatio when baackwards
		if (movingActionPressed > 0):
			move_and_collide(Vector2(0, -current_speed*delta).rotated(rotation))
		else:
			move_and_collide(Vector2(0, moveBackwardsRatio * current_speed*delta).rotated(rotation))
	#------------------------------Rotate
	if (rotatingActionPressed != 0):
		if (movingActionPressed == -1):											#Probably refactor this. Also in repeaters
			rotation -= 0.7 * rotatingActionPressed * rotation_speed * delta
		elif (movingActionPressed == 1):
			rotation += rotatingActionPressed * rotation_speed * delta
		else:
			move_and_collide(Vector2(0, 0))
			rotation += rotatingActionPressed * rotation_speed * delta * 0.5
	
	if (skillActionPressed == 1 and $WeaponCooldown.is_stopped()):
		$ShootComponent.shoot($Marker2D.global_position, rotation)

func _ready():
	$TankController.set_process(false)

func prepareTank():
	$HitComponent.prepare()

func makeTankAlive():
	is_alive = true
	$BodyDestroyed.visible = false
	$Body.visible = true
	$Weapon.visible = true
	$WeaponDestroyed.visible = false
	$WeaponCollision.disabled = false
	$BodyCollision.disabled = false
	$TankController.set_process(true)

func makeTankDead():
	is_alive = false
	$BodyDestroyed.visible = true
	$WeaponCollision.disabled = true
	$BodyCollision.disabled = true
	$Body.visible = false
	$Weapon.visible = false
	$WeaponDestroyed.visible = true
	$TankController.set_process(false)
	
	#if (name == "Player"):
		#var actionsArray = $TankController.addDeathRecord()
		#get_parent().receivePlayerRecordings(actionsArray)

func hit():
	makeTankDead()

func addMovementController(script):
	$TankController.set_script(script)

func _on_bullet_collision_body_entered(body):
	if (body.is_in_group("Bullet")):
		hit()
		body.onHit()
