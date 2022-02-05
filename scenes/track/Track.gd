tool
extends PanelContainer
class_name Track
class TrackData:
	var id: String
	var muted: bool
	var beats: Array
	var sample: Resource = preload("res://assets/samples/drums/snare_drum.wav")
	func _init(part_data):
		var num_beats = part_data.sig_lower * part_data.bars
		beats = []
		for i in range(num_beats):
			beats.append(false)

var data: TrackData
var part_data

const Beat = preload("res://scenes/beat/Beat.tscn")

signal delete()

export (NodePath) var path_muted
onready var node_muted :CheckBox = get_node(path_muted)

export (NodePath) var path_beats
onready var node_beats: Node = get_node(path_beats)

#var muted: bool = false setget set_muted, get_muted

func _ready():
	node_muted.connect("toggled", self, "set_muted")
	data = TrackData.new(part_data)
	deserialize(data)
	
func _on_tree_entered():
	pass

var next_beat_id = 0
var next_beat_time = 0.0
func _process(delta):
	if part_data.time >= next_beat_time:
		# seconds to past where sound should have been
		var time_error = part_data.time - next_beat_time
		
		node_beats.get_children()[next_beat_id % node_beats.get_child_count()].play()
		
		next_beat_id += 1
		next_beat_time = next_beat_id * (60.0 / part_data.bpm)
		
	
func _on_ButtonRemove_pressed():
	emit_signal("delete")

func get_score_global_rect():
	return Rect2($HBoxContainer/Score.rect_global_position, $HBoxContainer/Score.rect_size)

func set_muted(val):
	data.muted = val
	node_muted.pressed = val

func get_muted():
	assert(data.muted == node_muted.pressed)
	return node_muted.pressed
	
func deserialize(data: TrackData):
	if data != null:
		self.data = data
	# clear prev Beats
	for beat in node_beats.get_children():
		beat.queue_free()
	# Create new Beats
	for beat_is_on in data.beats:
		var beat = Beat.instance()
		beat.is_on = beat_is_on
		beat.sample = data.sample
		node_beats.add_child(beat)
	set_muted(data.muted)
	
func serialize():
	return inst2dict(data)
