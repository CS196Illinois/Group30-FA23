extends CharacterBody2D

# To be replaced with a system to detect the nearest planet once we instance multiple planets in the scene.
@onready var collider = $"PlayerCollider"
@onready var g = $"gravity"

var planets = {}
var current_planet

# Player movement constants
const MASS = 10
const MAX_FLYING_SPEED = 2000
const FLYING_ACCELERATION = 200

# Stores all the potential states that the player can be in, will be useful later to simplify complicated tasks.
enum states {
	GROUNDED,
	FALLING,
	FLYING
}

var current_state = states.FLYING

# Relative directions on the current planet.
var relative_up = Vector2.UP	
var relative_down = Vector2.DOWN
var relative_right = Vector2.RIGHT
var relative_left = Vector2.LEFT
var rel_up_last_frame = relative_up

var player_input = Vector2.ZERO
var input_velocity = Vector2.ZERO
var gravitational_pull = 0.0
var grounded_gravitational_pull = 0.0

var acceleration = Vector2.ZERO

func _process(delta):
	# Sets the rotation to be facing the right way relative to what is up on the planet's surface.
	rotation = Vector2.UP.angle_to(relative_up)

func _physics_process(delta):
	
	# absolute gravitational influence
	var gravitational_force = set_gravity()
	
	# player input
	match current_state:
		states.GROUNDED:
			pass
		states.FLYING:
			move_floating(delta)
			velocity = clamp_vector(input_velocity, MAX_FLYING_SPEED) * delta
			

		states.FALLING:
			move_floating(delta)
			velocity = (clamp_vector(input_velocity, MAX_FLYING_SPEED) + gravitational_force) * delta
			
			
	print(velocity.length())
	print(planets)
	move_and_slide()

# set gravity direction based on planet influence
func set_gravity():
	var gravity = Vector2.ZERO
	for i in planets:
		var direction = (planets[i].global_position - global_position).normalized()
		var influence = ((25000 * MASS * planets[i].MASS) / (position.distance_squared_to(planets[i].position) * 2))
		gravity += direction * influence
	print(gravity.length())
	g.target_position = gravity
	return gravity

'''func _physics_process(delta):
	var grav_direction = Vector2.ZERO
	for i in planets:
		var direction = -(global_position - planets[i].global_position).normalized()
		var influence = ((25000 * MASS * planets[i].MASS) / (position.distance_squared_to(planets[i].position) * 2))
		grav_direction += direction * influence
	
	# State machine.
	match current_state:
		states.GROUNDED:
			relative_up = (global_position - current_planet.global_position).normalized()
			relative_down = -relative_up.normalized()
			relative_left = Vector2(-relative_up.y, relative_up.x).normalized()
			relative_right = -relative_left.normalized()
			velocity = velocity.rotated(velocity.angle_to(current_planet.position))
			rotation = Vector2.UP.angle_to(relative_up)
			
			move_grounded(delta)
			
			velocity = relative_down * grounded_gravitational_pull + relative_left * lateral_movement
			
			if Input.is_action_just_pressed("jump"):
				velocity += relative_up * JUMP_STRENGTH
			
			if not is_grounded():
				current_state = states.FALLING

		states.FALLING:
			move_floating(delta)
			velocity = (Vector2(lateral_movement, vertical_movement) * 100 + grav_direction) * delta
			
			
			if is_grounded():
				current_state = states.GROUNDED
				
		states.FLYING: 
			move_floating(delta)
			velocity.x = lateral_movement
			velocity.y = vertical_movement
			velocity = clamp_vector(velocity, MAX_FLYING_SPEED)
			
	move_and_slide()'''

# Manipulates velocity according to gravitational formula.
func handle_gravity(delta):
	gravitational_pull = ((2000 * MASS * current_planet.MASS) / position.distance_squared_to(current_planet.position)) * delta

# Manipulates velocity according 
func move_floating(delta):
	player_input = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	input_velocity += player_input * FLYING_ACCELERATION 
	
# Manipulates velocity according to the player's lateral input (left, right).
func move_grounded(delta):
	player_input.x = Input.get_axis("move_left", "move_right") * delta

# Checks if the player is grounded using the floor collision raycast.
func is_grounded():
	return $RayDown.is_colliding()
	
# Clamps a vector at a given maximum length (will be useful when handling movement).
func clamp_vector(vector, maximum_length):
	if vector.length() > maximum_length:
		return vector.normalized() * maximum_length
	
	return vector

func _on_player_area_area_entered(area):
	if area.is_in_group("PlanetGravity"):
		if current_state != states.FALLING:
			current_state = states.FALLING
		var p = area.get_parent()
		planets[p.get_name()] = p
		
	elif area.is_in_group("OrientField"):
		current_planet = area.get_parent()
		if current_state != states.GROUNDED:
			current_state = states.GROUNDED


func _on_player_area_area_exited(area):
	if area.is_in_group("PlanetGravity"):
		var p = area.get_parent()
		planets.erase(p.get_name())
		if planets.is_empty():
			current_state = states.FLYING
		
		
