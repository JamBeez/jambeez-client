tool
extends PanelContainer
class_name Track
class TrackData:
	var id: String
	var muted: bool
	var beats: Array

var data: TrackData = TrackData.new()
var time: float = 0

signal delete()

export (NodePath) var path_muted
onready var node_muted :CheckBox = get_node(path_muted)
#var muted: bool = false setget set_muted, get_muted

func _ready():
	node_muted.connect("toggled", self, "set_muted")
	
	deserialize(data)
	
func _on_tree_entered():
	pass
	
func _on_ButtonRemove_pressed():
	emit_signal("delete")

func get_score_global_rect():
	return Rect2($HBoxContainer/Score.rect_global_position, $HBoxContainer/Score.rect_size)

func set_muted(val):
	print(val)
	data.muted = val
	node_muted.pressed = val

func get_muted():
	assert(data.muted == node_muted.pressed)
	return node_muted.pressed
	
func deserialize(data: TrackData):
	if data != null:
		self.data = data
	set_muted(data.muted)
	
func serialize():
	return inst2dict(data)
