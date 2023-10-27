extends CharacterBody2D

@export var max_speed = 50.0
@export var acceleration = 0.6

var forward_speed = 0.0

func get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
	if Input.is_action_pressed("throttle_down"):
		forward_speed = lerp(forward_speed, 0.0, acceleration * delta)

func _physics_process(delta):
	get_input(delta)
	move_and_collide(velocity * delta)
