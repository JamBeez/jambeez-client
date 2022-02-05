extends PanelContainer


var data: Data.Track
var part_data: Data.Part
var bus_id

const Beat = preload("res://scenes/beat/Beat.tscn")

signal delete()

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
	deserialize(data)
	
	Communicator.connect("set_sample", self, "_on_Communicator_set_sample")
	Communicator.connect("toggle_mute", self, "_on_Communicator_toggle_mute")
	Communicator.connect("change_volume", self, "_on_Communicator_change_volume")

	node_sample.clear()
	for sample in Consts.SAMPLES:
		node_sample.add_item(sample[0])

var next_beat_id = 0
func _process(delta):
	if node_beats.get_child_count() == 0:
		return
	
	var next_beat_time = next_beat_id * (60.0 / part_data.bpm)
	if part_data.time >= next_beat_time:
		# seconds to past where sound should have been
		var time_error = part_data.time - next_beat_time
		node_beats.get_children()[next_beat_id % node_beats.get_child_count()].play()
		next_beat_id += 1

func _on_ButtonRemove_pressed():
	Communicator.notify_remove_track(part_data.id, data.id)
	emit_signal("delete") # TODO remove
	
func _on_OptionButtonSample_item_selected(index):
	Communicator.notify_change_sample(part_data.id, data.id, index)
	set_sample(index) # TODO remove
func _on_ButtonMute_toggled(pressed):
	Communicator.notify_toggle_mute(part_data.id, data.id, pressed)
	toggle_mute(pressed) # TODO remove
func _on_HSlider_value_changed(value):
	Communicator.notify_change_volume(part_data.id, data.id, value)
	change_volume(value) # TODO remove

func _on_Communicator_set_sample(part_id, track_id, sample_id):
	if part_data.id == part_id and data.id == track_id:
		set_sample(sample_id)
func _on_Communicator_toggle_mute(part_id, track_id, muted):
	if part_data.id == part_id and data.id == track_id:
		toggle_mute(muted)
func _on_Communicator_change_volume(part_id, track_id, volume):
	if part_data.id == part_id and data.id == track_id:
		change_volume(volume)
	
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
	# TODO calc db
	
func get_score_global_rect():
	return Rect2($HBoxContainer/Score.rect_global_position, $HBoxContainer/Score.rect_size)
	
func deserialize(data: Data.Track):
	toggle_mute(data.muted)
	set_sample(data.sample_id)
	if data != null:
		self.data = data
	# clear prev Beats
	for beat in node_beats.get_children():
		beat.queue_free()
	# Create new Beats
	for beat_is_on in data.beats:
		var beat = Beat.instance()
		beat.is_on = beat_is_on
		beat.sample = Consts.SAMPLES[data.sample_id][1]
		beat.bus_id = bus_id
		node_beats.add_child(beat)
	
func serialize():
	return inst2dict(data)

