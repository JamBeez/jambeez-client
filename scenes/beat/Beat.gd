extends Button

var is_on = false
var sample: Resource
var bus_id = 0
var mouse_inside = false

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

func _input(event):
	# fix that mouse_entered is not called when mouse is already pressed
	if event is InputEventMouseMotion:
		if get_global_rect().has_point(event.position):
			if not mouse_inside and Input.is_mouse_button_pressed(BUTTON_LEFT):
				print("first inside")
				mouse_entered()
				mouse_inside = true
		else:
			mouse_inside = false

func mouse_entered():
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		pressed = !is_on

func mouse_exited():
	# mouse_inside = false
	pass
