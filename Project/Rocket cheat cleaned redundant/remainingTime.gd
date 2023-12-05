extends Label

var hasChanged = false

var time_left_String = ""
var time_left = 0

var ui_check_win = false
var ui_check_lose = false

var ui_fuel = 100
var ui_oxygen = 100


var check_cheat = false

func _process(delta):
	if not check_cheat:
		if ui_check_win:
			text = "YOU WIN!"
		elif ui_check_lose:
			text = "Gameover"
		else:
			
			text = str("Time Left: ", time_left_String, "\n", "Fuel: ", (roundi(ui_fuel * 10) / 10), " ", "Oxygen: ", (roundi(ui_oxygen * 10) / 10))
			
			if time_left <= 20 && !hasChanged:
				$change.play("urgent")
				hasChanged = true
			if time_left <= 0:
				text = "Gameover"
				ui_check_lose = true
	else:
		text = "YOU CHEAT!"
