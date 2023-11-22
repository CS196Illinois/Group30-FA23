class_name PlanetBarren extends RigidBody2D

@export var maxSpeed = 250.0
@export var minSpeed = 150.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$AnimatedSprite2D.playing = true
	var PlanetBarren_types = $AnimatedSprite2D.frames.get_animation_names() 
	$AnimatedSprite2D.animation = PlanetBarren_types[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
