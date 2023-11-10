extends Control

var menu_origin_position := Vector2.ZERO
var menu_origin_size := Vector2.ZERO
var menu_transition_time = 0.5
@onready var previous_window = DisplayServer.window_get_mode()
@onready var current_window = DisplayServer.window_get_mode()
@onready var master_bus_id = AudioServer.get_bus_index("Master")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sfx_bus_id = AudioServer.get_bus_index("SFX")
@onready var select = randi() % 5
@onready var previous: int

var current_menu
var menu_stack := []

func _ready() -> void:
	randomize()
	menu_origin_position = Vector2(0, 0)
	menu_origin_size = get_viewport_rect().size
	current_menu = main_menu
	menu_bgm.play()

func _process(delta):
	
	if select == 0 && select != previous:
		background_one.visible = true
		background_two.visible = false
		background_three.visible = false
		background_four.visible = false
		background_five.visible = false
	elif abs(parallax_background.scroll_base_offset.x) >= 1152:
		select = randi() % 5
	if select == 1 && select != previous:
		background_one.visible = false
		background_two.visible = true
		background_three.visible = false
		background_four.visible = false
		background_five.visible = false
	elif abs(parallax_background.scroll_base_offset.x) >= 1152:
		select = randi() % 5
	if select == 2 && select != previous:
		background_one.visible = false
		background_two.visible = false
		background_three.visible = true
		background_four.visible = false
		background_five.visible = false
	elif abs(parallax_background.scroll_base_offset.x) >= 1152:
		select = randi() % 5
	if select == 3 && select != previous:
		background_one.visible = false
		background_two.visible = false
		background_three.visible = false
		background_four.visible = true
		background_five.visible = false
	elif abs(parallax_background.scroll_base_offset.x) >= 1152:
		select = randi() % 5
	if select == 4 && select != previous:
		background_one.visible = false
		background_two.visible = false
		background_three.visible = false
		background_four.visible = false
		background_five.visible = true
	elif abs(parallax_background.scroll_base_offset.x) >= 1152:
		select = randi() % 5
	if menu_bgm.playing == false:
		menu_bgm.play()

	if abs(parallax_background.scroll_offset.x) >= 1152:
		animation_player.play("Transition")
		await get_tree().create_timer(0.5).timeout
		previous = select
		select = randi() % 5
		parallax_background.scroll_offset.x = 0

@onready var main_menu = $mainmenu
@onready var settings_menu = $settingsmenu
@onready var parallax_background = $ParallaxBackground
@onready var background_one = $ParallaxBackground/ParallaxLayer/background1
@onready var background_two = $ParallaxBackground/ParallaxLayer/background2
@onready var background_three = $ParallaxBackground/ParallaxLayer/background3
@onready var background_four = $ParallaxBackground/ParallaxLayer/background4
@onready var background_five = $ParallaxBackground/ParallaxLayer/background5
@onready var animation_player = $AnimationPlayer
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
	get_tree().change_scene_to_file("res://Scenes/test.tscn")

func _on_yes_pressed():
	click.play()
	await get_tree().create_timer(0.6).timeout
	get_tree().quit()

func _on_no_pressed():
	click.play()
	central.visible = true
	confirmation.visible = false

func _on_fullscreen_toggled(button_pressed):
	if button_pressed:
		current_window = DisplayServer.window_get_mode()
		if current_window != 4:
			previous_window = current_window
			DisplayServer.window_set_mode(4)
	else:
		if previous_window == 4:
			previous_window = 2
		DisplayServer.window_set_mode(previous_window)

func _on_masterslider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_id, value < .05)

func _on_musicslider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus_id, value < .05)

func _on_sfxslider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_id, value < .05)

