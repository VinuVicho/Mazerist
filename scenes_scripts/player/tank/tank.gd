class_name BasicTank extends PhysicsBody2D

#TODO: make player-tank and repeater-tank. remove TankController, and have this instead?

var inGamePlayerId: int = -1

@export var speed: int = 200;
@export var moveBackwardsRatio: float = 0.5;
@export var health: int = 1;
@export var rotation_speed: float = 2
@export var amount_of_bullets = 3

var disabled := false
var tankState: TankState = TankState.new()

# Starting position
var startingPosition: Vector2

func _init() -> void:
	tankState.current_speed = speed
	tankState.tankNode = self

func _process(delta):
	if (!tankState.is_alive):
		return
	##-------------------------------Move
	if (tankState.movingActionPressed != 0):
		if (tankState.movingActionPressed > 0):
			move_and_collide(Vector2(0, -delta * tankState.current_speed).rotated(rotation))
		else:
			move_and_collide(Vector2(0, moveBackwardsRatio * tankState.current_speed * delta).rotated(rotation))
	##------------------------------Rotate
	if (tankState.rotatingActionPressed != 0):
		if (tankState.movingActionPressed == -1):											#Probably refactor this. Also in repeaters
			rotation -= 0.7 * tankState.rotatingActionPressed * rotation_speed * delta
		elif (tankState.movingActionPressed == 1):
			rotation += tankState.rotatingActionPressed * rotation_speed * delta
		else:
			move_and_collide(Vector2(0, 0))
			rotation += tankState.rotatingActionPressed * rotation_speed * delta * 0.5
	
	if (tankState.shootActionPressed and $WeaponCooldown.is_stopped()):
		shoot()

func prepareTank():
	$HitComponent.prepare()

func makeTankAlive():
	if disabled: return
	resetTank()
	#TODO: move this to TankState class
	tankState.is_alive = true
	tankState.isHoldingArtefact = false
	$WeaponCollision.disabled = false
	$ObjectsCollision.monitoring = true
	$BodyCollision.disabled = false
	$TankController.startControl()
	$TankController.set_process(true)

func resetTank():
	resetTankAppereance()
	tankState.movingActionPressed = 0
	tankState.rotatingActionPressed = 0
	tankState.shootActionPressed = false
	tankState.actions = []

	tankState.is_alive = false
	tankState.current_speed = speed
	
	rotation = 0
	position = startingPosition
func resetTankAppereance():
	$BodyDestroyed.visible = false
	$Body.visible = true
	$Weapon.visible = true
	$WeaponDestroyed.visible = false

func makeTankDead(shouldKillTank: bool = true):
	tankState.is_alive = false
	if tankState.isHoldingArtefact:
		tankState.isHoldingArtefact = false
		var artefact = tankState.artefact
		artefact.position = position
		artefact.visible = visible
		artefact.set_deferred("monitorable", true)
		$AuraSprite.visible = false
	
	$WeaponCollision.set_deferred("disabled", true)
	$BodyCollision.set_deferred("disabled", true)
	$ObjectsCollision.set_deferred("monitoring", false)
	$TankController.set_process(false)
	if shouldKillTank: killTank()

func killTank():
	$BodyDestroyed.visible = true
	$Body.visible = false
	$Weapon.visible = false
	$WeaponDestroyed.visible = true
	$TankController.recordAction(Enums.ActionType.TANK_DIED)

func setTankDisabled(d: bool):
	disabled = d
	visible = !d

func shoot():
	if tankState.is_alive:
		$ShootComponent.shoot($Marker2D.global_position, rotation)
		$TankController.recordAction(Enums.ActionType.SHOOT)

func hit(bullet: Node2D):
	makeTankDead()
	Global.gameService.tankDied(self, bullet)

func addMovementController(script):
	$TankController.set_script(script)

func _on_collision_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Bullet")):
		hit(body)
		body.onHit()

func _on_objects_collision_area_entered(area: Area2D) -> void:
	if !area.canIteract(inGamePlayerId): return
	if area.is_in_group("Base"):
		if tankState.isHoldingArtefact:
			Global.gameService.artifactDelivered(inGamePlayerId)
			$AuraSprite.visible = false
			tankState.isHoldingArtefact = false
			tankState.artefact = null
			Logger.log("Artefact delivered by " + str(inGamePlayerId))			#TODO: show in game
	if area.is_in_group("Artefact"):
		$AuraSprite.visible = true
		area.visible = false
		tankState.isHoldingArtefact = true
		tankState.artefact = area
		area.set_deferred("monitorable", false)
