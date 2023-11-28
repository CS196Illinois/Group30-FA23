extends CharacterBody2D

# To be replaced with a system to detect the nearest planet once we instance multiple planets in the scene.
@onready var planet = $"../Planet"

# Player movement constants
const MASS = 10
const SPEED = 5000
const JUMP_STRENGTH = 500
const TERMINAL_VELOCITY = 20
const MAX_WALK_SPEED = 20

# Stores all the potential states that the player can be in, will be useful later to simplify complicated tasks.
enum states {
	GROUNDED,
	FALLING,
	FLYING
}

var current_state = states.FALLING

# Relative directions on the current planet.
var relative_up = Vector2.UP	
var relative_down = Vector2.DOWN
var relative_right = Vector2.RIGHT
var relative_left = Vector2.LEFT
var rel_up_last_frame = relative_up

var lateral_movement = 0.0
var gravitational_pull = 0.0

func _physics_process(delta):
	# Relative player direction vectors.
	relative_up = (global_position - planet.global_position).normalized()
	relative_down = -relative_up.normalized()
	relative_left = Vector2(relative_up.y, -relative_up.x).normalized()
	relative_right = -relative_left.normalized()
	
	# Sets the rotation to be facing the right way relative to what is up on the planet's surface.
	rotation = Vector2.UP.angle_to(relative_up)
	
	# State machine.
	match current_state:
		
		states.GROUNDED:
			velocity = velocity.rotated(velocity.angle_to(planet.position))
			
			move_grounded(delta)
			
			velocity = relative_down * gravitational_pull + relative_left * lateral_movement
			
			if Input.is_action_just_pressed("jump"):
				velocity += relative_up * JUMP_STRENGTH
			
			if not is_grounded():
				current_state = states.FALLING

		states.FALLING:
			handle_gravity(delta)
			velocity = relative_down * gravitational_pull + relative_left * lateral_movement
			if is_grounded():
				current_state = states.GROUNDED
	
		states.FLYING: 
			move_floating(delta)
	move_and_slide()

# Manipulates velocity according to gravitational formula.
func handle_gravity(delta):
	gravitational_pull = ((667 * MASS * planet.MASS ) / position.distance_squared_to(planet.position)) * delta

# Manipulates velocity according t
func move_floating(delta):
	velocity += Input.get_action_strength("move_left") * relative_left + Input.get_action_strength("move_right") * relative_right 

# Manipulates velocity according to the player's lateral input (left, right).
func move_grounded(delta):
	lateral_movement = Input.get_axis("move_left", "move_right") * SPEED * delta

# Checks if the player is grounded using the floor collision raycast.
func is_grounded():
	return $RayDown.is_colliding()
	
# Clamps a vector at a given maximum length (will be useful when handling movement).
func clamp_vector(vector, maximum_length):
	if vector.length() > maximum_length:
		return vector.normalized() * maximum_length
	
	return vector
