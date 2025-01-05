extends PhysicsBody2D

var speed = 350		#/1.5
var time_life         = 100
var parent_tank_id    = -1
var velocity: Vector2 = Vector2(0, 0)

func _ready():
	$LifeTime.start(time_life)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

func setVelocity(vector: Vector2):
	velocity = vector * speed

func onHit():
	queue_free()

func _on_life_time_timeout(): queue_free()
