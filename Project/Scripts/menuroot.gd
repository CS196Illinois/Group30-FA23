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
	menu_bgm.play()

func _process(delta):
	if (menu_bgm.playing == false):
		menu_bgm.play()

@onready var main_menu = $mainmenu
@onready var settings_menu = $settingsmenu
@onready var back_button = $settingsmenu/center/vertical/back
@onready var start_button = $mainmenu/center/vertical/start
@onready var settings_button = $mainmenu/center/vertical/settings
@onready var exit_button = $mainmenu/center/vertical/exit
@onready var central = $mainmenu/center
@onready var confirmation = $mainmenu/confirmation
@onready var click = get_parent().get_node("click")
@onready var menu_bgm = get_parent().get_node("menubgm")

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
	click.play()
	central.visible = false
	confirmation.visible = true

func _on_settings_pressed():
	click.play()
	back_button.disabled = true
	move_to_next_menu("settings_menu")
	await get_tree().create_timer(0.65).timeout
	back_button.disabled = false

func _on_back_pressed():
	click.play()
	start_button.disabled = true
	settings_button.disabled = true
	exit_button.disabled = true
	move_to_prev_menu()
	await get_tree().create_timer(0.65).timeout
	start_button.disabled = false
	settings_button.disabled = false
	exit_button.disabled = false

func _on_start_pressed():
	click.play()

func _on_yes_pressed():
	click.play()
	await get_tree().create_timer(0.6).timeout
	get_tree().quit()

func _on_no_pressed():
	click.play()
	central.visible = true
	confirmation.visible = false
