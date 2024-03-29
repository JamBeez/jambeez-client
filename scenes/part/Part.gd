tool
extends MarginContainer

var data: Data.Part = Data.Part.new()

signal setting_sig_upper_changed(sig_upper)
signal setting_sig_lower_changed(sig_lower)
signal setting_bpm_changed(bpm)
signal setting_bars_changed(bars)

var time_max: float = 100 # TODO

const Track = preload("res://scenes/track/Track.tscn")

export (NodePath) var path_sig_upper
onready var input_sig_upper:LineEdit = get_node(path_sig_upper).get_line_edit()

export (NodePath) var path_sig_lower
onready var input_sig_lower:LineEdit = get_node(path_sig_lower).get_line_edit()

export (NodePath) var path_bpm
onready var input_bpm:LineEdit = get_node(path_bpm).get_line_edit()

export (NodePath) var path_bars
onready var input_bars:LineEdit = get_node(path_bars).get_line_edit()

export (NodePath) var path_tracks
onready var node_tracks:Node = get_node(path_tracks)

export (NodePath) var path_needle
onready var node_needle:Control = get_node(path_needle)

export (NodePath) var path_sample
onready var node_sample:Control = get_node(path_sample)

func _ready():
	Communicator.connect("add_track", self, "_on_Communicator_add_track")
	Communicator.connect("remove_track", self, "_on_Communicator_remove_track")
	
	Communicator.connect("change_sig_upper", self, "_on_Communicator_change_sig_upper")
	Communicator.connect("change_sig_lower", self, "_on_Communicator_change_sig_lower")
	Communicator.connect("change_BPM", self, "_on_Communicator_change_BPM")
	Communicator.connect("change_bars", self, "_on_Communicator_change_bars")
	
	node_sample.clear()
	for sample in Consts.SAMPLES:
		node_sample.add_item(sample[0])
		
	deserialize()
	
	# Runtime warn-error because Part from Editor get deleted befor yield
	# TODO DF: I've disabled yield here. It causes errors in the log : Resumed function '_ready()' after yield
	# yield(get_tree(), "idle_frame")
	update_needle()
	update_time()

var delta_last = 0
var next_beat_id:int = 0
func _physics_process(delta):
	data.time_last = data.time
	data.time += delta
	delta_last = delta
	
	if(needle_x_min != needle_x_max):
		node_needle.rect_position.x = lerp(needle_x_min, needle_x_max, fmod(data.time, time_max) / time_max)
	
	var next_beat_time = next_beat_id * data.spb
	if data.time >= next_beat_time:
		# seconds to past where sound should have been
		var time_error = data.time - next_beat_time
		
		if(node_tracks):
			for track in node_tracks.get_children():
				track.play_beat(next_beat_id, time_error)
		next_beat_id += 1
	
func update_time():
	time_max = (60.0 / data.bpm) * (data.sig_lower * data.bars)
	
var needle_x_min = 0
var needle_x_max = 0
func update_needle():
	if !node_tracks:
		return
	if node_tracks.get_child_count() == 0:
		node_needle.visible = false
		return
	else:
		node_needle.visible = true
	
	yield(get_tree(), "idle_frame")
	
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
	var track_data = Data.Track.new(data)
	track_data.sample_id = node_sample.selected
	#add_track(track_data)
	Communicator.notify_add_track(data.id, track_data)
	
func add_track(track_data: Data.Track):
	var child = Track.instance()
	child.data = track_data
	child.part_data = self.data
	node_tracks.add_child(child)
	yield(get_tree(), "idle_frame")
	update_needle()

func delete_track(child):
	data.tracks.erase(child.data)
	node_tracks.remove_child(child)
	update_needle()


func _on_SpinBoxSigUpper_value_changed(new_text):
	if int(new_text) == data.sig_upper: return
	Communicator.notify_sig_upper(data.id, int(new_text))

func _on_SpinBoxSigLower_value_changed(new_text):
	if int(new_text) == data.sig_lower: return
	Communicator.notify_sig_lower(data.id, int(new_text))

func _on_SpinBoxBars_value_changed(new_text):
	if int(new_text) == data.bars: return
	Communicator.notify_bars(data.id, int(new_text))
	
func _on_SpinBoxBPM_value_changed(new_text):
	if int(new_text) == data.bpm: return
	Communicator.notify_BPM(data.id, int(new_text))
	

func _on_Communicator_add_track(part_id, track):
	if data.id != part_id: return
	add_track(Data.Track.from_dict(track, data))
func _on_Communicator_remove_track(part_id, track_id):
	if data.id != part_id: return
	for track in node_tracks.get_children():
		if track.data.id == track_id:
			delete_track(track)
	
func _on_Communicator_change_BPM(part_id, value):
	if data.id != part_id: return
	
	var bps = data.bpm / 60.0
	var time_in_beats = data.time * bps
	data.bpm = value
	bps = data.bpm / 60.0
	
	data.time = time_in_beats / bps
	data.time_last = data.time - delta_last
	
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
	
	var res = _calc_new_time_when_beats_per_pass_change(data, value * data.bars)
	data.time = res[0]
	next_beat_id = res[1]
	data.time_last = data.time - delta_last
	data.sig_lower = value
	
	input_sig_lower.text = str(value)
	for track in node_tracks.get_children():
		track.data.change_time_sig(data)
		track.deserialize(null)
		Communicator.notify_set_beats(data.id, track.data.id, track.data.beats)
	update_time()
	update_needle()
	emit_signal("setting_sig_lower_changed", value)
	
func _on_Communicator_change_bars(part_id, value):
	if data.id != part_id: return
	
	var res = _calc_new_time_when_beats_per_pass_change(data, value * data.sig_lower)
	data.time = res[0]
	next_beat_id = res[1]
	data.time_last = data.time - delta_last
	data.bars = value
	
	input_bars.text = str(value)
	
	for track in node_tracks.get_children():
		track.data.change_time_sig(data)
		track.deserialize(null)
		Communicator.notify_set_beats(data.id, track.data.id, track.data.beats)
		
	update_time()
	update_needle()
	emit_signal("setting_bars_changed", value)

func _calc_new_time_when_beats_per_pass_change(data: Data.Part, new_num_beats_per_pass):
	var bps = data.bpm / 60.0
	
	var time_in_beats = data.time * bps # [b]
	var beats_per_pass = data.bars * data.sig_lower # [b/p]
	var time_per_pass = beats_per_pass / bps # [s/p]
	var num_passes = int(time_in_beats / beats_per_pass)
	
	var time_in_this_pass = (data.time - num_passes * time_per_pass) 
	var beats_in_this_pass = time_in_this_pass * bps
	
	return [
		(num_passes * new_num_beats_per_pass + beats_in_this_pass) / bps,
		new_num_beats_per_pass * num_passes + ceil(beats_in_this_pass)
		]
	
func deserialize(new_data: Data.Part = null):
	if new_data != null:
		data = new_data
	elif data == null:
		printerr("data is null can't deserialise Part")
		
	# update ui
	name = data.id
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
	
