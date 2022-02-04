tool
extends MarginContainer

signal setting_sig_upper_changed(sig_upper)
signal setting_sig_lower_changed(sig_lower)
signal setting_bpm_changed(bpm)
signal setting_bars_changed(bars)

var setting_sig_upper = 4
var setting_sig_lower = 4
var setting_bpm = 120
var setting_bars = 2

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

func _on_ButtonTrackAdd_pressed():
	pass # Replace with function body.

func _on_LineEditSigUpper_text_entered(new_text):
	var new_int = int(new_text)
	if new_int != setting_sig_upper:
		setting_sig_upper = new_int
		emit_signal("setting_sig_upper_changed", setting_sig_upper)
func _on_LineEditSigUpper_focus_exited():
	_on_LineEditSigUpper_text_entered(input_sig_lower.text)

func _on_LineEditSigLower_text_entered(new_text):
	var new_int = int(new_text)
	if new_int != setting_sig_lower:
		setting_sig_lower = new_int
		emit_signal("setting_sig_upper_changed", setting_sig_lower)
func _on_LineEditSigLower_focus_exited():
	_on_LineEditSigLower_text_entered(input_sig_upper.text)

func _on_LineEditBPM_text_entered(new_text):
	var new_int = int(new_text)
	if new_int != setting_bpm:
		setting_bpm = new_int
		emit_signal("setting_bpm", setting_bpm)
func _on_LineEditBPM_focus_exited():
	_on_LineEditSigUpper_text_entered(input_bpm.text)

func _on_LineEditBars_text_entered(new_text):
	var new_int = int(new_text)
	if new_int != setting_bars:
		setting_bars = new_int
		emit_signal("setting_bars", setting_bars)
func _on_LineEditBars_focus_exited():
	_on_LineEditSigUpper_text_entered(input_bars.text)
