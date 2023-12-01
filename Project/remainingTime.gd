extends Label

var time = 10
var is_timer_on = true
var hasChanged = false
var hasPlayed = false

func _process(delta):
	if is_timer_on:
		time -= delta
	var milliseconds = fmod(time, 1) * 1000
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 60 * 60) / 60
	var time_passed = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	text = time_passed
	if time <= 60 && !hasChanged:
		$change.play("urgent")
		hasChanged = true
	if time <= 0:
		is_timer_on = false
		text = "Gameover"
	if time <= 0 && !hasPlayed:
		$VideoStreamPlayer.play()
		hasPlayed = true
