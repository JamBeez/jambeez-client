extends PanelContainer


var data: Data.Track
var part_data: Data.Part
var bus_id

const Beat = preload("res://scenes/beat/Beat.tscn")
const BarLine = preload("res://scenes/track/BarLine.tscn")
const APLHA_MUTE = 0.5

export (NodePath) var path_sample
onready var node_sample: OptionButton = get_node(path_sample)

export (NodePath) var path_volume
onready var node_volume: HSlider = get_node(path_volume)

export (NodePath) var path_muted
onready var node_muted :CheckBox = get_node(path_muted)

export (NodePath) var path_beats
onready var node_beats: Node = get_node(path_beats)

export (NodePath) var path_bar_lines
onready var node_bar_lines: Node = get_node(path_bar_lines)

func _ready():
	AudioServer.add_bus()
	bus_id = AudioServer.bus_count - 1
	node_sample.clear()
	for sample in Consts.SAMPLES:
		node_sample.add_item(sample[0])
	deserialize(data)
	
	Communicator.connect("set_sample", self, "_on_Communicator_set_sample")
	Communicator.connect("toggle_mute", self, "_on_Communicator_toggle_mute")
	Communicator.connect("change_volume", self, "_on_Communicator_change_volume")
	Communicator.connect("set_beats", self, "_on_Communicator_set_beats")


func play_beat(id, time_error=0.0):
	if !data.muted:
		var beat = node_beats.get_child(id % data.beats.size())
		beat.play(part_data.spb, time_error)

func _on_ButtonRemove_pressed():
	Communicator.notify_remove_track(part_data.id, data.id)
func _on_OptionButtonSample_item_selected(index):
	Communicator.notify_change_sample(part_data.id, data.id, index)
func _on_ButtonMute_toggled(pressed):
	Communicator.notify_toggle_mute(part_data.id, data.id, pressed)
var prevent_volume_signal = false
func _on_HSlider_value_changed(value):
	if !prevent_volume_signal:
		Communicator.notify_change_volume(part_data.id, data.id, value)
func _on_beat_toggled(is_on, idx):
	data.beats[idx] = is_on
	Communicator.notify_set_beats(part_data.id, data.id, data.beats)
	
func _on_Communicator_set_sample(part_id, track_id, sample_id):
	if part_data.id == part_id and data.id == track_id:
		set_sample(sample_id)
func _on_Communicator_toggle_mute(part_id, track_id, muted):
	if part_data.id == part_id and data.id == track_id:
		toggle_mute(muted)
func _on_Communicator_change_volume(part_id, track_id, volume):
	if part_data.id == part_id and data.id == track_id:
		change_volume(volume)
func _on_Communicator_set_beats(part_id, track_id, beats, color_per_beat):
	if part_data.id == part_id and data.id == track_id:
		set_beats(beats, color_per_beat)

func set_sample(sample_id):
	data.sample_id = sample_id
	node_sample.selected = data.sample_id
	for beat in node_beats.get_children():
		beat.change_sample(data.sample_id) 
func toggle_mute(val):
	data.muted = val
	node_muted.pressed = val
	modulate.a = APLHA_MUTE if val else 1
	node_muted.modulate.a = 1 / APLHA_MUTE if val else 1
	AudioServer.set_bus_mute(bus_id, val)
func change_volume(val):
	prevent_volume_signal = true
	data.volume = val
	call_deferred("set", "prevent_volume_signal", false)
	node_volume.value = val
	AudioServer.set_bus_volume_db(bus_id, linear2db(val / 100.0))
	
func set_beats(beats, color_per_beat):
	data.beats = beats
	data.color_per_beat = color_per_beat
	
	var old_size = node_beats.get_child_count()
	var new_size = len(beats)
	var size_diff = new_size - old_size
	
	if size_diff > 0: # add new beats
		for i in range(old_size, new_size):
			var beat = Beat.instance()
			beat.is_on = data.beats[i]
			if not data.color_per_beat.empty():
				beat.set_color(data.color_per_beat[i])
			beat.sample = Consts.SAMPLES[data.sample_id][1]
			beat.bus_id = bus_id
			beat.connect("beat_toggled", self, "_on_beat_toggled", [i])
			node_beats.add_child(beat)

	var children = node_beats.get_children()
	
	# remove overflowing beats
	if size_diff < 0:
		for i in range(new_size, old_size):
			node_beats.remove_child(children[i])

	# update existing beats
	for i in range(min(old_size, new_size)):
		children[i].set_is_on(beats[i])
		children[i].set_color(color_per_beat[i])
		i += 1
	
	
func get_score_global_rect():
	return Rect2($HBoxContainer/Score.rect_global_position, $HBoxContainer/Score.rect_size)
	
func deserialize(new_data: Data.Track):
	if new_data != null:
		data = new_data
	elif data == null:
		printerr("data is null can't deserialise Track")
	
	toggle_mute(data.muted)
	set_sample(data.sample_id)
	change_volume(data.volume)
	set_beats(data.beats, data.color_per_beat)
	update_bar_lines()

func _on_Score_resized():
	update_bar_lines()
func update_bar_lines():
	# Update BarLines
	for bar_line in node_bar_lines.get_children():
		bar_line.queue_free()
	yield(get_tree(), "idle_frame")
	for i in range(1, part_data.bars):
		var bar_line:Node = BarLine.instance()
		node_bar_lines.add_child(bar_line)
		bar_line.position.x = (float(i) / part_data.bars) * float(node_bar_lines.rect_size.x)
		
func serialize():
	return inst2dict(data)
