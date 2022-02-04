extends Node

signal connection_state_changed(is_connected)
signal change_BPM(bpm)

# TODO adjust url
const _websocket_url = "ws://echo.websocket.events/.ws"
var _client = WebSocketClient.new()
var _is_connected = false

func notify_BPM(bpm):
	# TODO better format
	_send_data("bpm is now " + str(bpm))

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(_websocket_url)
	if err != OK:
		printerr("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	_is_connected = false
	emit_signal("connection_state_changed", _is_connected)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_is_connected = true
	emit_signal("connection_state_changed", _is_connected)
	# TODO remove test packet send
	_send_data("Test packet")

func _send_data(message: String):
	if _is_connected:
		_client.get_peer(1).put_packet(message.to_utf8())
		
func _on_data():
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(delta):
	_client.poll()
