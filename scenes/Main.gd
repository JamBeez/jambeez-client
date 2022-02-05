extends Node2D

export (NodePath) var path_connection
onready var node_connection:CheckButton = get_node(path_connection)

export (NodePath) var path_join
onready var node_join:Button = get_node(path_join)

export (NodePath) var path_invite
onready var node_invite:Node = get_node(path_invite)

export (NodePath) var path_invite_link
onready var node_invite_link:LineEdit = get_node(path_invite_link)

func _ready():
	Communicator.connect("connection_state_changed", self, "_on_Communicator_connection_state_changed")
	Communicator.connect("request_lobby", self, "_on_Communicator_request_lobby")

func _on_Communicator_connection_state_changed(state):
	print(state)
	match state:
		"connecting":
			node_connection.text = "Connecting..."
			node_connection.set_pressed_no_signal(true)
			node_connection.disabled = true
		"connected":
			node_connection.text = "Connected"
			node_invite.visible = true
			node_join.visible = false
			node_connection.set_pressed_no_signal(true)
			node_connection.disabled = false
		"closed":
			node_connection.text = "Share Session"
			node_invite.visible = false
			node_join.visible = true
			node_connection.set_pressed_no_signal(false)
			node_connection.disabled = false

func _on_Communicator_request_lobby(lobby_id):
	node_invite_link.text = Consts.HTTP_SERVER_URL + "/" + lobby_id
	print("Created lobby with id " + str(lobby_id))

func _on_ConnectionToogle_toggled(button_pressed):
	if button_pressed:
		Communicator.start_connection()
	else:
		Communicator.stop_connection()
