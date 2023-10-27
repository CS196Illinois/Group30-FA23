extends Area2D

func _ready():
	var rand = randi_range(4, 8)
	scale.x = rand
	scale.y = rand

