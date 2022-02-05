tool
extends MarginContainer

signal setting_sig_upper_changed(sig_upper)
signal setting_sig_lower_changed(sig_lower)
signal setting_bpm_changed(bpm)
signal setting_bars_changed(bars)

var part_id = randi() # TODO
var time: float = 0
var time_max: float = 100 # TODO
var setting_sig_upper = 4
var setting_sig_lower = 4
var setting_bpm = 120
var setting_bars = 2

var TrackScene = preload("res://scenes/track/Track.tscn")
var Track = preload("res://scenes/track/Track.gd")

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
	input_sig_upper.text = str(setting_sig_upper)
	input_sig_lower.text = str(setting_sig_lower)
	input_bpm.text = str(setting_bpm)
	input_bars.text = str(setting_bars)
	
	Communicator.connect("change_BPM", self, "_on_Communicator_change_BPM")
	
	yield(get_tree(), "idle_frame")
	update_needle()
	update_time()

func _process(delta):
	time += delta
	time = fmod(time, time_max)
	
	node_needle.rect_position.x = lerp(needle_x_min, needle_x_max, time / time_max)
	
	for track in node_tracks.get_children():
		track.time = time
	
func update_time():
	time = 0
	time_max = (60.0 / setting_bpm) * (setting_sig_lower * setting_bars)
	
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
	var data = Track.TrackData.new()
	data.muted = true
	add_track(data)
	
func add_track(data): #Track.TrackData
	var child = TrackScene.instance()
	child.data = data
	child.connect("delete", self, "delete_track", [child])
	node_tracks.add_child(child)
	yield(get_tree(), "idle_frame")
	update_needle()

func delete_track(child):
	# TODO propagete to server
	node_tracks.remove_child(child)
	update_needle()

func _on_LineEditBPM_text_entered(new_text):
	Communicator.notify_BPM(part_id, int(new_text))
	
func _on_LineEditBPM_focus_exited():
	_on_LineEditBPM_text_entered(input_bpm.text)
	
func _on_Communicator_change_BPM(part_id, bpm):
	if self.part_id != part_id:
		return
	setting_bpm = bpm
	input_bpm.text = str(bpm)
	update_time()
	update_needle()
	emit_signal("setting_bpm_changed", bpm)
	print("BPM was set to " + str(bpm))



