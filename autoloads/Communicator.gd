extends Node

signal connection_state_changed(state)
signal lobby_create(lobby_id)
signal lobby_join(lobby)
signal add_part(part)
signal change_BPM(part_id, bpm)
signal add_track(part_id, track)

var _client = WebSocketClient.new()
var _is_connected = false

var PARAM_WS_SERVER_URL: String
var serialize_main: FuncRef

func notify_request_lobby():
	var msg = {
		"intent" : "lobby:create",
	}
	_send_data(JSON.print(msg))
func notify_join_lobby(lobby_id: String):
	var msg = {
		"intent" : "lobby:join",
		"lobby_id" : lobby_id
	}
	_send_data(JSON.print(msg))
func notify_update_parts(lobby: Data.Lobby):
	var msg = {
		"intent" : "lobby:update_parts",
		"parts" : lobby.parts
	}
	_send_data(JSON.print(msg))
func notify_BPM(part_id: String, bpm: int):
	var msg = {
		"intent" : "part:change_bpm",
		"part_id" : part_id,
		"value" : bpm
	}
	_send_data(JSON.print(msg))
func notify_add_track(part_id: String, track: Data.Track):
	var msg = {
		"intent" : "part:add_track",
		"part_id" : part_id,
		"track_data" : track
	}
	_send_data(JSON.print(msg))

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	
	if OS.is_debug_build() and OS.has_feature("JavaScript"):
		PARAM_WS_SERVER_URL = JavaScript.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("ws_url");
		""")

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
	var url = PARAM_WS_SERVER_URL if PARAM_WS_SERVER_URL else Consts.WS_SERVER_URL
	var err = _client.connect_to_url(url)
	print("Connecting to: ", url)
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
		print(data_json)
		match data_json.intent:
			"lobby:create":
				if data_json.get("lobby_id") == null:
					data_json.lobby_id = "i-am-a-drum-bee" # TODO remove
					print("lobby:create : Mocking lobby id ", data_json.lobby_id)
					
				# TODO change url so that it can be shared but without triggering website reload
				
				emit_signal("lobby_create", data_json.lobby_id)
				
				var data = serialize_main.call_func()
				print(data)
				notify_update_parts(serialize_main.call_func())
			"lobby:join":
				var lobby: Data.Lobby
				if data_json.get("lobby") == null:
					lobby = Consts.initial_lobby
					print("lobby:join : Mocking lobby ", lobby)
				else:
					lobby = data_json.lobby
				
				emit_signal("lobby_join", lobby)
			"user:joined":
				pass
			"lobby:update_parts":
				notify_update_parts(serialize_main.call_func())
			"part:add_track":
				emit_signal("add_track", data_json.part_id, data_json.track)
			"track:change_bpm":
				emit_signal("change_BPM", data_json.part_id, data_json.value)

func _process(delta):
	_client.poll()
