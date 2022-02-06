extends Node2D

#var data: Data.Lobby = Data.initial_state
var data = Data.initial_state

const Part = preload("res://scenes/part/Part.tscn")

export (NodePath) var path_connection
onready var node_connection:CheckButton = get_node(path_connection)

export (NodePath) var path_join
onready var node_join:Button = get_node(path_join)

export (NodePath) var path_invite
onready var node_invite:Node = get_node(path_invite)

export (NodePath) var path_invite_link
onready var node_invite_link:LineEdit = get_node(path_invite_link)

export (NodePath) var path_tab_cont
onready var node_tab_cont:TabContainer = get_node(path_tab_cont)


func _ready():
	Communicator.connect("connection_state_changed", self, "_on_Communicator_connection_state_changed")
	Communicator.connect("lobby_create", self, "_on_Communicator_lobby_create")
	Communicator.connect("lobby_join", self, "_on_Communicator_lobby_join")
	Communicator.get_main_data = funcref(self, "get_data")
	
	deserialize()

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
		"disconnected":
			node_connection.text = "Share Session"
			node_invite.visible = false
			node_join.visible = true
			node_connection.set_pressed_no_signal(false)
			node_connection.disabled = false

func _on_Communicator_lobby_create(lobby_id: String):
	node_invite_link.text = Consts.get_invite_link(lobby_id)
	print("Created lobby with id " + str(lobby_id))

func _on_Communicator_lobby_join(lobby: Data.Lobby):
	deserialize(lobby)
	node_invite_link.text = Consts.get_invite_link(lobby.id)
	print("Joined lobby with id " + lobby.id)

func _on_ConnectionToogle_toggled(button_pressed):
	if button_pressed:
		Communicator.start_connection()
	else:
		Communicator.stop_connection()


func add_part(part_data: Data.Part):
	var child = Part.instance()
	child.data = part_data
	child.connect("delete", self, "delete_track", [child])
	node_tab_cont.add_child(child)

func delete_track(child):
	node_tab_cont.remove_child(child)

func deserialize(new_data: Data.Lobby = null):
	if new_data != null:
		data = new_data
	elif data == null:
		printerr("data is null can't deserialise Lobby")
	
	# clear prev 
	for part in node_tab_cont.get_children():
		part.queue_free()
	# Create new Tracks
	for part_data in data.parts:
		add_part(part_data)


func get_data() -> Data.Lobby:
	return data

func _on_ButtonInviteCopy_pressed():
	OS.set_clipboard(node_invite_link.text)
