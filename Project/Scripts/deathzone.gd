extends Area2D
@export var mass = 1000000


func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Death")
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
