extends Label

var time = 60
var is_timer_on = true
var hasChanged = false

var ui_check_win = false
var ui_check_lose = false

var ui_fuel = 100
var ui_oxygen = 100

var display = "String"

func _process(delta):
	if ui_check_win:
		text = "YOU WIN!"
	elif ui_check_lose:
		text = "Gameover"
	else:
		if is_timer_on:
			time -= delta
		var milliseconds = fmod(time, 1) * 1000
		var seconds = fmod(time, 60)
		var minutes = fmod(time, 60 * 60) / 60
		var time_passed = "%02d:%02d" % [minutes, seconds]
		
		display = str("Time Left: ", time_passed, "\n", "Fuel: ", roundi(ui_fuel * 10) / 10, " ", "Oxygen: ", roundi(ui_oxygen * 10) / 10)
		text = display
		if time <= 60 && !hasChanged:
			$change.play("urgent")
			hasChanged = true
		if time <= 0:
			is_timer_on = false
			text = "Gameover"
