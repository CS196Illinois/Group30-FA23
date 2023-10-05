extends Node2D

var mass = 1000
var vegetation = true

var land = false	#whether ship lands on the planet
var crush = false	#whether ship crushes
var fuel = false
var crushSpeed = 400


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



func _on_plante_forest_area_body_exited(body):
	land = false
