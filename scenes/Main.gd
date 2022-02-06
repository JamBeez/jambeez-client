extends Node2D

#var data: Data.Lobby = Data.initial_state
var data = Data.initial_state

const Part = preload("res://scenes/part/Part.tscn")

export (NodePath) var path_connection
onready var node_connection:CheckButton = get_node(path_connection)

export (NodePath) var path_invite
onready var node_invite:Node = get_node(path_invite)

export (NodePath) var path_tab_cont
onready var node_tab_cont:TabContainer = get_node(path_tab_cont)


func _ready():
	Communicator.connect("connection_state_changed", self, "_on_Communicator_connection_state_changed")
	Communicator.connect("lobby_create", self, "_on_Communicator_lobby_create")
	Communicator.connect("lobby_join", self, "_on_Communicator_lobby_join")
	Communicator.connect("lobby_error", self, "_on_Communicator_lobby_error")
	Communicator.get_main_data = funcref(self, "get_data")
	
	node_invite.connect("join", self, "_on_invite_join")
	node_invite.set_state(Data.State.DISCONNECTED, Consts.PARAM_LOBBY_ID)
	
	deserialize()

func _on_Communicator_connection_state_changed(state):
	match state:
		Data.ConnectionState.CONNECTING:
			node_connection.text = "Connecting..."
			node_connection.set_pressed_no_signal(true)
			node_connection.disabled = true
		Data.ConnectionState.CONNECTED:
			node_connection.text = "Connected"
			node_connection.set_pressed_no_signal(true)
			node_connection.disabled = false
		Data.ConnectionState.DISCONNECTING:
			node_connection.text = "Share Session"
			node_connection.set_pressed_no_signal(false)
			node_connection.disabled = false
			node_invite.set_state(Data.State.DISCONNECTED)

func _on_Communicator_lobby_create(lobby_id: String):
	node_invite.set_state(Data.State.IN_LOBBY, Consts.to_invite_link(lobby_id))
	print("Created lobby with id " + str(lobby_id))

func _on_Communicator_lobby_join(lobby: Data.Lobby):
	deserialize(lobby)
	node_invite.set_state(Data.State.IN_LOBBY, Consts.to_invite_link(lobby.id))
	print("Joined lobby with id " + lobby.id)
	
func _on_Communicator_lobby_error(message: String):
	print(message)

func _on_ConnectionToogle_toggled(button_pressed):
	if button_pressed:
		Communicator.start_connection()
	else:
		Communicator.stop_connection()
		
func _on_invite_join(lobby_id: String):
	Communicator.start_connection(lobby_id)
	Communicator.notify_join_lobby(lobby_id)

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

onready var fileDialog:FileDialog = $CanvasLayer/FileDialog
onready var btnRec = $CanvasLayer/MarginContainer/VBoxContainer/Footer/HBoxContainer/ButtonRec
onready var btnDownload = $CanvasLayer/MarginContainer/VBoxContainer/Footer/HBoxContainer/ButtonDownload
var is_recording = false
var current_record = null
func _on_ButtonRec_pressed():
	if is_recording:
		var effect:AudioEffectRecord = AudioServer.get_bus_effect(0, 0)
		current_record = effect.get_recording()
		effect.set_recording_active(false)
		btnRec.text = "Rec"
		btnDownload.visible = true
	else:
		var effect:AudioEffectRecord = AudioServer.get_bus_effect(0, 0)
		effect.set_recording_active(true)
		btnRec.text = "Stop Rec"
	is_recording = !is_recording
	
export var s:AudioStreamSample

func _on_ButtonDownload_pressed():
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		_download_sound()
	else:
		# Default Download for non HTML5
		fileDialog.popup_centered()


func _on_FileDialog_file_selected(path:String):
	var wavData : Array = _get_wave_data()
	if wavData.size() == 0:
		return

	if(!path.ends_with(".wav")):
		path = path + ".wav"
		
	var file :File = File.new()
	file.open(path, File.WRITE)
	file.store_buffer(wavData)
	file.close()
	
func _download_sound():
	var wavData : Array = _get_wave_data()
	if wavData.size() == 0:
		return
	JavaScript.download_buffer(wavData, "jambeez.wav")

func _get_wave_data() -> Array:
	var effect:AudioEffectRecord = AudioServer.get_bus_effect(0, 0)
	var recording = effect.get_recording()
	print("saving wav to tmp in user://")
	recording.save_to_wav("user://export_temp.wav")
	var file:File = File.new()
	if file.open("user://export_temp.wav", File.READ):
		# On Error do nothing for now
		return Array()
	print("Store WAV to Buffer")
	var wavData = Array(file.get_buffer(file.get_len()))
	file.close()
	var dir = Directory.new()
	dir.remove("user://export_temp.wav")
	return wavData
