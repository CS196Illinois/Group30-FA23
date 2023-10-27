extends CharacterBody2D

@export var speed: float = 750
var vel = Vector2()

func _physics_process(delta):
	position += transform.x * speed * delta
	

func start_at(dir, pos):
	set_rotation(dir * (3.14 / 2))
	set_position(pos * (3.14 / 2))
	vel = Vector2(speed, 0).rotated(dir)

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

