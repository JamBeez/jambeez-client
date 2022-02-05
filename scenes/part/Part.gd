extends MarginContainer

var data: Data.Part = Data.Part.new()

signal setting_sig_upper_changed(sig_upper)
signal setting_sig_lower_changed(sig_lower)
signal setting_bpm_changed(bpm)
signal setting_bars_changed(bars)

var time_max: float = 100 # TODO

const Track = preload("res://scenes/track/Track.tscn")

export (NodePath) var path_sig_upper
onready var input_sig_upper:LineEdit = get_node(path_sig_upper)

export (NodePath) var path_sig_lower
onready var input_sig_lower:LineEdit = get_node(path_sig_lower)

export (NodePath) var path_bpm
onready var input_bpm:LineEdit = get_node(path_bpm)

export (NodePath) var path_bars
onready var input_bars:LineEdit = get_node(path_bars)

export (NodePath) var path_tracks
onready var node_tracks:Node = get_node(path_tracks)

export (NodePath) var path_needle
onready var node_needle:Control = get_node(path_needle)

func _ready():
	Communicator.connect("change_sig_upper", self, "_on_Communicator_change_sig_upper")
	Communicator.connect("change_sig_lower", self, "_on_Communicator_change_sig_lower")
	Communicator.connect("change_BPM", self, "_on_Communicator_change_BPM")
	Communicator.connect("change_bars", self, "_on_Communicator_change_bars")
	
	deserialize(data)
	
	yield(get_tree(), "idle_frame")
	update_needle()
	update_time()

func _process(delta):
	data.time_last = data.time
	data.time += delta
	
	node_needle.rect_position.x = lerp(needle_x_min, needle_x_max, fmod(data.time, time_max) / time_max)
	
func update_time():
	data.time = 0
	time_max = (60.0 / data.bpm) * (data.sig_lower * data.bars)
	
	
var needle_x_min = 0
var needle_x_max = 0
func update_needle():
	if !node_tracks or node_tracks.get_child_count() == 0:
		return
	
	var track_first:Control = node_tracks.get_child(0)
	var track_last:Control = node_tracks.get_child(node_tracks.get_child_count() - 1)
	
	node_needle.rect_global_position.x = track_first.get_score_global_rect().position.x
	node_needle.rect_global_position.y = track_first.rect_global_position.y
	
	node_needle.rect_size.y = track_last.rect_global_position.y + track_last.rect_size.y - track_first.rect_global_position.y
	
	needle_x_min = node_needle.rect_position.x
	needle_x_max = needle_x_min + track_first.get_score_global_rect().size.x

func _on_Part_resized():
	update_needle()
	
func _on_ButtonTrackAdd_pressed():
	var data = Data.Track.new(self.data)
	data.muted = true
	add_track(data)
	
func add_track(data: Data.Track):
	var child = Track.instance()
	child.data = data
	child.part_data = self.data
	child.connect("delete", self, "delete_track", [child])
	node_tracks.add_child(child)
	yield(get_tree(), "idle_frame")
	update_needle()

func delete_track(child):
	# TODO propagete to server
	node_tracks.remove_child(child)
	update_needle()


func _on_LineEditSigUpper_text_entered(new_text):
	if int(new_text) == data.sig_upper: return
	Communicator.notify_sig_upper(data.id, int(new_text))
func _on_LineEditSigUpper_focus_exited(): _on_LineEditSigUpper_text_entered(input_sig_upper.text)

func _on_LineEditSigLower_text_entered(new_text):
	if int(new_text) == data.sig_lower: return
	Communicator.notify_sig_lower(data.id, int(new_text))
func _on_LineEditSigLower_focus_exited(): _on_LineEditSigLower_text_entered(input_sig_lower.text)

func _on_LineEditBars_text_entered(new_text):
	if int(new_text) == data.bars: return
	Communicator.notify_bars(data.id, int(new_text))
func _on_LineEditBars_focus_exited(): _on_LineEditBars_text_entered(input_bars.text)
	
func _on_LineEditBPM_text_entered(new_text):
	if int(new_text) == data.bpm: return
	Communicator.notify_BPM(data.id, int(new_text))
func _on_LineEditBPM_focus_exited(): _on_LineEditBPM_text_entered(input_bpm.text)
	
func _on_Communicator_change_BPM(part_id, value):
	if data.id != part_id: return
	data.bpm = value
	input_bpm.text = str(value)
	update_time()
	update_needle()
	emit_signal("setting_bpm_changed", value)

func _on_Communicator_change_sig_upper(part_id, value):
	if data.id != part_id: return
	data.sig_upper = value
	input_sig_upper.text = str(value)
	update_time()
	update_needle()
	emit_signal("setting_sig_upper_changed", value)

func _on_Communicator_change_sig_lower(part_id, value):
	if data.id != part_id: return
	data.sig_lower = value
	input_sig_lower.text = str(value)
	update_time()
	update_needle()
	emit_signal("setting_sig_lower_changed", value)

func _on_Communicator_change_bars(part_id, value):
	if data.id != part_id: return
	data.bars = value
	input_bars.text = str(value)
	update_time()
	update_needle()
	emit_signal("setting_bars_changed", value)

func deserialize(data: Data.Part):
	if data != null:
		self.data = data
	
	# update ui
	input_sig_upper.text = str(data.sig_upper)
	input_sig_lower.text = str(data.sig_lower)
	input_bpm.text = str(data.bpm)
	input_bars.text = str(data.bars)
	update_time()
	update_needle()
	
	# clear prev Tracks
	for track in node_tracks.get_children():
		track.queue_free()
	# Create new Tracks
	for track_data in data.tracks:
		add_track(track_data)
	
