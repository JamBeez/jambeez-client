extends Node

signal connection_state_changed(is_connected)
signal change_BPM(part_id, bpm)

const _websocket_url = "ws://echo.websocket.events/.ws" # TODO adjust url
var _client = WebSocketClient.new()
var _is_connected = false

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

func start_connection():
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(_websocket_url)
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
	emit_signal("connection_state_changed", _is_connected)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_is_connected = true
	emit_signal("connection_state_changed", _is_connected)

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

func _process(delta):
	_client.poll()
