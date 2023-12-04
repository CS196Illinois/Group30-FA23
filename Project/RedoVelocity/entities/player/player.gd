extends CharacterBody2D

# To be replaced with a system to detect the nearest planet once we instance multiple planets in the scene.
@onready var collider = $"PlayerCollider"
@onready var g = $"gravity"

var planets = {}
var current_planet

# Player movement constants
const MASS = 10
const FLYING_ACCELERATION = 10
const ROTATE_SPEED = 1.6

const FUEL_CONSUME_RATE = 10
const MAX_FUEL = 1000000
const FUEL_REFILLING_RATE = 20

const MAX_OXYGEN = 100
const OXYGEN_CONSUME_RATE = 2
const OXYGEN_REFILLING_RATE = 5

const A_SINGLE_JUMP = 30

# Stores all the potential states that the player can be in, will be useful later to simplify complicated tasks.
enum states {
	GROUNDED,
	FALLING,
	FLYING
}

var current_state = states.FLYING

# Relative directions on the current planet.
var relative_up = Vector2.UP	
var rotation_vector = Vector2.ZERO

var player_input = Vector2.ZERO
var input_velocity = Vector2.ZERO
var gravitational_pull = 0.0
var grounded_gravitational_pull = 0.0

var acceleration = Vector2.ZERO

# Fuel System & Oxygen System
var fuel = MAX_FUEL
var oxygen = MAX_OXYGEN
var run_out_of_oxygen = false

#Jump System
var jump_up_scenes = 0
var jump_down_scenes = 0
var jump_right_scenes = 0
var jump_left_scenes = 0
var jump_scaler = 0.5
var jump_scenes_decrease = 2

var jump_escape_scenes = 0



func _process(delta):
	# Sets the rotation to be facing the right way relative to what is up on the planet's surface.
	rotation = Vector2.UP.angle_to(relative_up)

func _physics_process(delta):
	
	# absolute gravitational influence
	var gravitational_force = set_gravity()
	
	if not run_out_of_oxygen:
		oxygen -= OXYGEN_CONSUME_RATE * delta
	if oxygen <= 0:
		run_out_of_oxygen = true
		print("run out of oxygen!")
	
	# player input
	match current_state:
		states.GROUNDED:
			relative_up = (global_position - current_planet.global_position).normalized()
			
			
			if not is_grounded():
				if jump_escape_scenes < 0.1:
					velocity += gravitational_force * delta
				else: 
					jump(delta, true, false)
					# do not add gravitational_force here
			else:
				velocity = Vector2.ZERO
				jump(delta, true, true)
				move_floating(delta)
				if player_input.x > 0:
					rotation_vector = (-current_planet.global_position + global_position).rotated(ROTATE_SPEED * delta)
					global_position = current_planet.global_position + rotation_vector
				if player_input.x < 0:
					rotation_vector = (-current_planet.global_position + global_position).rotated(-ROTATE_SPEED * delta)
					global_position = current_planet.global_position + rotation_vector
					
			
			
			# check whether to add fuel
			if current_planet.has_fuel: 
				if fuel < MAX_FUEL:
					fuel += FUEL_REFILLING_RATE * delta
					fuel = clamp(MAX_FUEL, 0, fuel)
			
			if current_planet.has_oxygen: 
				if oxygen < MAX_OXYGEN:
					oxygen += OXYGEN_REFILLING_RATE * delta
					oxygen = clamp(MAX_OXYGEN, 0, oxygen)
			
			if Input.is_action_just_pressed("jump"):
				current_state = states.FALLING
			
		states.FLYING:
			move_floating(delta)
			jump(delta, false, false)
			velocity += input_velocity * delta
			
			
		states.FALLING:
			move_floating(delta)
			jump(delta, false, false)
			velocity += input_velocity * delta
			if jump_escape_scenes < 0.01:
				velocity += gravitational_force * delta
			
			
			if is_grounded():
				current_state = states.GROUNDED
		
		
	print("Fuel Amount: ", fuel)
	#print("speed: ", velocity.length())
	print("Oxygen: ", oxygen)

	
	
	move_and_slide()

# set gravity direction based on planet influence
func set_gravity():
	var gravity = Vector2.ZERO
	for i in planets:
		var direction = (planets[i].global_position - global_position).normalized()
		var influence = 1000 * MASS * planets[i].MASS / position.distance_squared_to(planets[i].position)
		gravity += direction * influence
	g.target_position = gravity
	return gravity



# Manipulates velocity according to gravitational formula.
func handle_gravity(delta):
	gravitational_pull = ((200 * MASS * current_planet.MASS) / position.distance_squared_to(current_planet.position)) * delta

# Manipulates velocity according 
func move_floating(delta):
	player_input = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	if (fuel > 0) && (not player_input == Vector2.ZERO):
		fuel -= FUEL_CONSUME_RATE * delta
	if fuel > 0:
		input_velocity = player_input * FLYING_ACCELERATION 

func jump(delta, check_on_ground, check_can_jump):
	if not check_on_ground:
		
		if Input.is_action_just_pressed("jump") && (not player_input.length() == 0):
			jump_scaler = 2.5
			jump_scenes_decrease = 5
			if fuel >= 5:
				fuel -= 5
				if player_input.x > 0:
					jump_right_scenes += A_SINGLE_JUMP
				if player_input.x < 0:
					jump_left_scenes += A_SINGLE_JUMP
				if player_input.y > 0:
					jump_down_scenes += A_SINGLE_JUMP
				if player_input.y < 0:
					jump_up_scenes += A_SINGLE_JUMP
				
		if jump_up_scenes > 0.1:
			velocity += Vector2.UP * jump_up_scenes * jump_up_scenes * jump_scaler * delta
			jump_up_scenes /= jump_scenes_decrease
		if jump_down_scenes > 0.1:
			velocity += Vector2.DOWN * jump_down_scenes * jump_down_scenes * jump_scaler * delta
			jump_down_scenes /= jump_scenes_decrease
		if jump_right_scenes > 0.1:
			velocity += Vector2.RIGHT * jump_right_scenes * jump_right_scenes * jump_scaler * delta
			jump_right_scenes /= jump_scenes_decrease
		if jump_left_scenes > 0.1:
			velocity += Vector2.LEFT * jump_left_scenes * jump_left_scenes * jump_scaler * delta
			jump_left_scenes /= jump_scenes_decrease
		
		
	if check_on_ground:
		jump_up_scenes = 0
		jump_down_scenes = 0
		jump_right_scenes = 0
		jump_left_scenes = 0
		
		jump_scaler = 2
		jump_scenes_decrease = 5
		if jump_escape_scenes > 0.1:
			velocity += (global_position - current_planet.global_position).normalized() * jump_escape_scenes * jump_escape_scenes * jump_scaler * delta
			jump_escape_scenes /= jump_scenes_decrease
		
		if check_can_jump:
			if Input.is_action_just_pressed("jump"):
				fuel -= 0
				jump_escape_scenes += A_SINGLE_JUMP * 3
			

			

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
	elif area.is_in_group("OrientField"):
		current_planet = null
		current_state = states.FALLING
		
