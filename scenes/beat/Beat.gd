tool
extends Button

var is_on = false
var sample: Resource
var bus_id = 0

onready var player:AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	player.stream = sample
	player.bus = AudioServer.get_bus_name(bus_id)
	pressed = is_on

func play():
	if is_on:
		player.play(0)

func change_sample(sample_id: int):
	sample = Consts.SAMPLES[sample_id][1]
	player.stream = sample

func _on_Beat_toggled(button_pressed):
	is_on = button_pressed
