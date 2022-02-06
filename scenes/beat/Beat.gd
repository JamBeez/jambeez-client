extends Button


var is_on = false
var color = []
var sample: Resource
var bus_id = 0
var mouse_inside = false

signal beat_toggled(pressed)

onready var player:AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	player.stream = sample
	player.bus = AudioServer.get_bus_name(bus_id)
	set_pressed_no_signal(is_on)
	
	
func play(blink_duration = 0):
	if is_on:
		player.play(0)
		if blink_duration > 0:
			add_stylebox_override("pressed", Consts.beat_style_active)
			$Timer.start(blink_duration)
			
func _on_Timer_timeout():
	add_stylebox_override("pressed", Consts.beat_style_normal)

func change_sample(sample_id: int):
	sample = Consts.SAMPLES[sample_id][1]
	player.stream = sample

func _on_Beat_toggled(button_pressed):
	emit_signal("beat_toggled", button_pressed)
	
func set_is_on(is_on):
	self.is_on = is_on
	set_pressed_no_signal(is_on)
	if !is_on:
		modulate = Color(1, 1, 1)

func set_color(color):
	self.color = color
	if color.empty() or !is_on:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(color[0], color[1], color[2])

func _input(event):
	# fix that mouse_entered is not called when mouse is already pressed
	if event is InputEventMouseMotion:
		if get_global_rect().has_point(event.position):
			if not mouse_inside:
				mouse_entered()
		else:
			mouse_inside = false

func mouse_entered():
	if mouse_inside: # _input races with the original mouse_entered
		return
	mouse_inside = true
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		pressed = !is_on
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		pressed = false

func mouse_exited():
	mouse_inside = false



