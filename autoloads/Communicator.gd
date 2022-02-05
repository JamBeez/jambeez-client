extends Node

signal connection_state_changed(state)
signal change_BPM(part_id, bpm)
signal request_lobby(lobby_id)
signal join_lobby(lobby_id, a_lot_of_data)

var _client = WebSocketClient.new()
var _is_connected = false

func notify_request_lobby():
	var msg = {
		"intent" : "request_lobby"
	}
	_send_data(JSON.print(msg))
func notify_join_lobby(lobby_id):
	var msg = {
		"intent" : "join_lobby",
		"lobby_id" : lobby_id
	}
	_send_data(JSON.print(msg))
	
func notify_BPM(part_id, bpm):
	var msg = {
		"intent" : "change_bpm",
		"part_id" : part_id,
		"value" : bpm
	}
	_send_data(JSON.print(msg))

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	yield(get_tree(), "idle_frame")
	start_connection()

func get_browser_get_parameter():
	if OS.has_feature("JavaScript"):
		return JavaScript.eval(""" 
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("lobby_id");
		""")
	return null

func start_connection():
	emit_signal("connection_state_changed", "connecting")
	var err = _client.connect_to_url(Consts.WS_SERVER_URL)
	if err != OK:
		printerr("Unable to connect")
		set_process(false)

func stop_connection():
	_client.disconnect_from_host()
	
func start_sharing():
	start_connection()

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	_is_connected = false
	emit_signal("connection_state_changed", "closed")
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_is_connected = true
	emit_signal("connection_state_changed", "connected")
	
	var get_param = get_browser_get_parameter()
	if get_param:
		notify_join_lobby(get_param)
	else:
		notify_request_lobby()

func _send_data(message: String):
	if _is_connected:
		print("SEND:    ", message)
		_client.get_peer(1).put_packet(message.to_utf8())
		
func _on_data():
	var data_str = _client.get_peer(1).get_packet().get_string_from_utf8()
	var result = JSON.parse(data_str)
	print("RECEIVE: ", data_str)
	
	if result.error != OK:
		printerr("Error parsing JSON: " + result.error_string)
	else:
		var data_json = result.result
		match data_json.intent:
			"change_bpm":
				emit_signal("change_BPM", data_json.part_id, data_json.value)
			"request_lobby":
				data_json.lobby_id = 123 # TODO remove
				emit_signal("request_lobby", data_json.lobby_id)
			"join_lobby":
				data_json.lobby_id = 123 # TODO remove
				emit_signal("join_lobby", data_json.lobby_id, {"data":"value"})

func _process(delta):
	_client.poll()
