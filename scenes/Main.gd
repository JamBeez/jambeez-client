extends Node2D

export (NodePath) var path_connection
onready var node_connection:CheckButton = get_node(path_connection)

export (NodePath) var path_join
onready var node_join:Button = get_node(path_join)

export (NodePath) var path_invite
onready var node_invite:Node = get_node(path_invite)

func _ready():
	Communicator.connect("connection_state_changed", self, "_on_Communicator_connection_state_changed")

func _on_Communicator_connection_state_changed(is_connected):
	if is_connected:
		node_connection.text = "Connected"
		node_invite.visible = true
		node_join.visible = false
	else:
		node_connection.text = "Share Session"
		node_invite.visible = false
		node_join.visible = true


func _on_ConnectionToogle_toggled(button_pressed):
	if button_pressed:
		node_connection.text = "Connecting..."
		Communicator.start_sharing()
	else:
		Communicator.stop_connection()
