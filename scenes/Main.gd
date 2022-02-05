extends Node2D

var data: Data.Lobby = Data.Lobby.new()
#var data: LobbyData = LobbyData.from_dict(Consts.initial_lobby("i-am-a-drum-bee"))

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
	Communicator.connect("lobby_create", self, "_on_Communicator_lobby_create")
	Communicator.connect("lobby_join", self, "_on_Communicator_lobby_join")
	Communicator.serialize_main = funcref(self, "serialize")

func _on_Communicator_connection_state_changed(state):
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

func _on_Communicator_lobby_create(lobby_id):
	node_invite_link.text = Consts.get_invite_link(lobby_id)
	print("Created lobby with id " + str(lobby_id))

func _on_Communicator_lobby_join(lobby):
	data = lobby
	node_invite_link.text = Consts.get_invite_link(lobby.id)
	print("Joined lobby with id " + str(lobby.id))

func _on_ConnectionToogle_toggled(button_pressed):
	if button_pressed:
		Communicator.start_connection()
	else:
		Communicator.stop_connection()
		
func serialize():
	return inst2dict(data)
