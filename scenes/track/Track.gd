extends PanelContainer


var data: Data.Track
var part_data: Data.Part
var bus_id

const Beat = preload("res://scenes/beat/Beat.tscn")

export (NodePath) var path_sample
onready var node_sample: OptionButton = get_node(path_sample)

export (NodePath) var path_volume
onready var node_volume: HSlider = get_node(path_volume)

export (NodePath) var path_muted
onready var node_muted :CheckBox = get_node(path_muted)

export (NodePath) var path_beats
onready var node_beats: Node = get_node(path_beats)

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

var next_beat_id:int = 0
func _process(delta):
	if node_beats.get_child_count() == 0:
		return
	
	var next_beat_time = next_beat_id * (60.0 / part_data.bpm)
	if part_data.time >= next_beat_time:
		# seconds to past where sound should have been
		var time_error = part_data.time - next_beat_time
		node_beats.get_children()[next_beat_id % data.beats.size()].play()
		if data.beats[next_beat_id % data.beats.size()]:
			print(next_beat_id, " / ", data.beats.size())
		next_beat_id += 1
		

func _on_ButtonRemove_pressed():
	Communicator.notify_remove_track(part_data.id, data.id)
func _on_OptionButtonSample_item_selected(index):
	Communicator.notify_change_sample(part_data.id, data.id, index)
func _on_ButtonMute_toggled(pressed):
	Communicator.notify_toggle_mute(part_data.id, data.id, pressed)
var is_awaiting_volume_change = false
func _on_HSlider_value_changed(value):
	if !is_awaiting_volume_change:
		Communicator.notify_change_volume(part_data.id, data.id, value)
	is_awaiting_volume_change = true
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
func _on_Communicator_set_beats(part_id, track_id, beats):
	if part_data.id == part_id and data.id == track_id:
		set_beats(beats)

func set_sample(sample_id):
	data.sample_id = sample_id
	node_sample.selected = data.sample_id
	for beat in node_beats.get_children():
		beat.change_sample(data.sample_id) 
func toggle_mute(val):
	data.muted = val
	node_muted.pressed = val
	AudioServer.set_bus_mute(bus_id, val)
func change_volume(val):
	data.volume = val
	node_volume.value = val
	is_awaiting_volume_change = false
	# TODO calc db
	AudioServer.set_bus_volume_db(bus_id, linear2db(val / 100.0))
	
func set_beats(beats):
	data.beats = beats
	
	var old_size = node_beats.get_child_count()
	var new_size = len(beats)
	var size_diff = new_size - old_size
	
	if size_diff > 0: # add new beats
		for i in range(old_size, new_size):
			var beat = Beat.instance()
			beat.is_on = data.beats[i]
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
	set_beats(data.beats)
	
func serialize():
	return inst2dict(data)

