class_name LearnTutorial extends AnimatedSprite2D

@export var speed = 500.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("moveRight"):
		direction.x += 1
	if Input.is_action_pressed("moveLeft"):
		direction.x -= 1
	if Input.is_action_pressed("moveUp"):
		direction.y -= 1
	if Input.is_action_pressed("moveDown"):
		direction.y += 1
	
	if direction.length() > 1:
		direction = direction.normalized()
	
	position += direction * speed * delta
	
