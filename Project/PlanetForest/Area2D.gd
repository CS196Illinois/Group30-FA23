class_name PlaetForest extends Area2D


@export var mass = 1000 #set some value
var vegetation = true

var land = false	#whether ship lands on the planet
var crush = false	#whether ship crushes
@export var fuel = false
var crushSpeed = 400 #set some value


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_plante_forest_area_body_entered(body):
	land = true
	if body.speed > crushSpeed:		# Speed
		crush = true
	if fuel: 
		pass
