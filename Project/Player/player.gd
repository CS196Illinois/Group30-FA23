extends CharacterBody2D

# Get the Bullet
var plBullet = preload("res://Bullet/bullet.tscn")

# Necessary Variables
@onready var firingPositions := $FiringPositions
@onready var animatedSprite := $AnimatedSprite2D
@onready var animatedBullet := $BulletAnimation2D
@onready var fireDelayTimer := $FireDelayTimer

@export var speed: float = 100
@export var accelerationX: float = 300
@export var accelerationY: float = 500
@export var fireDelay: float = 0.25

var vel := Vector2(0, 0)
var dirVec := Vector2(0, 0)
var acc = Vector2(accelerationX, accelerationY)
var mouse_position = null


func _process(_delta):
	
	# Check if Shooting
	if Input.is_action_pressed("shoot") and fireDelayTimer.is_stopped() :
		fireDelayTimer.start(fireDelay)
		
		for child in firingPositions.get_children():
			var bullet = plBullet.instantiate()
			bullet.global_position = child.global_position
			get_tree().current_scene.add_child(bullet)
			bullet.transform = $FiringPositions.global_transform
	

func _physics_process(delta):
	
	vel = Vector2(0, 0)
	mouse_position = get_global_mouse_position()
	
	# Input Motion
	if Input.is_action_pressed("move_left"):
		dirVec.x += -1 * acc.x
		var direction = (mouse_position - position).normalized()
		vel = (direction * speed)
	elif Input.is_action_pressed("move_right"):
		dirVec.x += 1 * acc.x
		var direction = (mouse_position - position).normalized()
		vel = (direction * speed)
	if Input.is_action_pressed("move_up"):
		dirVec.y += -1 * acc.y
		var direction = (mouse_position - position).normalized()
		vel = (direction * speed)
	elif Input.is_action_pressed("move_down"):
		dirVec.y += 1 * acc.y
		var direction = (mouse_position - position).normalized()
		vel = (direction * speed)
	
	vel = dirVec.normalized() * speed
	position += vel * delta
	look_at(mouse_position)



