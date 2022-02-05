tool
extends MarginContainer

signal setting_sig_upper_changed(sig_upper)
signal setting_sig_lower_changed(sig_lower)
signal setting_bpm_changed(bpm)
signal setting_bars_changed(bars)

var part_id = randi() # TODO
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

func _ready():
	input_sig_upper.text = str(setting_sig_upper)
	input_sig_lower.text = str(setting_sig_lower)
	input_bpm.text = str(setting_bpm)
	input_bars.text = str(setting_bars)
	
	Communicator.connect("change_BPM", self, "_on_Communicator_change_BPM")

func _on_ButtonTrackAdd_pressed():
	var data = Track.TrackData.new()
	data.muted = true
	add_track(data)
	
func add_track(data): #Track.TrackData
	var child = TrackScene.instance()
	child.data = data
	$VBoxContainer/Tracks.add_child(child)

func _on_LineEditBPM_text_entered(new_text):
	Communicator.notify_BPM(part_id, int(new_text))
	
func _on_LineEditBPM_focus_exited():
	_on_LineEditBPM_text_entered(input_bpm.text)
	
func _on_Communicator_change_BPM(part_id, bpm):
	if self.part_id != part_id:
		return
	setting_bpm = bpm
	input_bpm.text = str(bpm)
	emit_signal("setting_bpm_changed", bpm)
	print("BPM was set to " + str(bpm))
