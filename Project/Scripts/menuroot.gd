extends Control

var menu_origin_position := Vector2.ZERO
var menu_origin_size := Vector2.ZERO
var menu_transition_time = 0.5

var current_menu
var menu_stack := []

func _ready() -> void:
	menu_origin_position = Vector2(0, 0)
	menu_origin_size = get_viewport_rect().size
	current_menu = main_menu


@onready var main_menu = $mainmenu
@onready var settings_menu = $settingsmenu

func move_to_next_menu(next_menu_id: String):
	var next_menu = get_menu_from_id(next_menu_id)
	var tween = create_tween()
	tween.parallel().tween_property(next_menu, "global_position", menu_origin_position, menu_transition_time)
	tween.parallel().tween_property(current_menu, "global_position", Vector2(-menu_origin_size.x, 0), menu_transition_time)
	menu_stack.append(current_menu)
	current_menu = next_menu


func move_to_prev_menu():
	var previous_menu = menu_stack.pop_back()
	var tween = create_tween()
	if previous_menu != null:
		tween.parallel().tween_property(previous_menu, "global_position", menu_origin_position, menu_transition_time)
		tween.parallel().tween_property(current_menu, "global_position", Vector2(menu_origin_size.x, 0), menu_transition_time)
		current_menu = previous_menu

func get_menu_from_id(menu_id: String) -> Control:
	match menu_id:
		"main_menu":
			return main_menu
		"settings_menu":
			return settings_menu
		_:
			return main_menu


func _on_exit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	move_to_next_menu("settings_menu")


func _on_back_pressed():
	move_to_prev_menu()


