extends PanelContainer


var data: Data.Track
var part_data
var bus_id

const Beat = preload("res://scenes/beat/Beat.tscn")

signal delete()

export (NodePath) var path_sample
onready var node_sample: OptionButton = get_node(path_sample)

export (NodePath) var path_muted
onready var node_muted :CheckBox = get_node(path_muted)

export (NodePath) var path_beats
onready var node_beats: Node = get_node(path_beats)

#var muted: bool = false setget set_muted, get_muted

func _ready():
	node_muted.connect("toggled", self, "set_muted")
	data = Data.Track.new(part_data)
	AudioServer.add_bus()
	bus_id = AudioServer.bus_count - 1
	deserialize(data)
	
	node_sample.clear()
	for sample in Consts.SAMPLES:
		node_sample.add_item(sample[0])
	
func _on_tree_entered():
	pass

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


func _on_OptionButtonSample_item_selected(index):
	data.sample_id = index

	# TODO do this after server message
	for beat in node_beats.get_children():
		beat.change_sample(data.sample_id) 
		
func _on_ButtonRemove_pressed():
	emit_signal("delete")

func get_score_global_rect():
	return Rect2($HBoxContainer/Score.rect_global_position, $HBoxContainer/Score.rect_size)

func set_muted(val):
	data.muted = val
	node_muted.pressed = val
	AudioServer.set_bus_mute(bus_id, val)

func get_muted():
	assert(data.muted == node_muted.pressed)
	return node_muted.pressed
	
	
func deserialize(data: Data.Track):
	node_sample.selected = data.sample_id
	set_muted(data.muted)
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

