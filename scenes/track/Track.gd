extends PanelContainer

class TrackData:
	var muted : bool

var data: TrackData = TrackData.new()

export (NodePath) var path_muted
onready var node_muted :CheckBox = get_node(path_muted)
#var muted: bool = false setget set_muted, get_muted

func _ready():
	node_muted.connect("toggled", self, "set_muted")
	
	
	deserialize(data)
	
func _on_tree_entered():
	pass
	
func set_muted(val):
	print(val)
	data.muted = val
	node_muted.pressed = val
	
	print(serialize())

func get_muted():
	assert(data.muted == node_muted.pressed)
	return node_muted.pressed
	
func deserialize(data: TrackData):
	if data != null:
		self.data = data
	set_muted(data.muted)
	
func serialize():
	return inst2dict(data)
