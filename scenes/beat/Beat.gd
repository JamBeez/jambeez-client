extends Button

var is_on = false
var sample: Resource

onready var player:AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	player.stream = sample
	pressed = is_on

func play():
	if is_on:
		player.play(0)


func _on_Beat_toggled(button_pressed):
	is_on = button_pressed
