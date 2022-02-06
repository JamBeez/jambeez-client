extends Node

signal connection_state_changed(state)
signal lobby_create(lobby_id)
signal lobby_join(lobby)
signal add_part(part)
signal change_BPM(part_id, bpm)
signal change_bars(part_id, bars)
signal change_sig_lower(part_id, sig_lower)
signal change_sig_upper(part_id, sig_upper)
signal add_track(part_id, track)
signal remove_track(part_id, track_id)
signal set_sample(part_id, track_id, sample_id)
signal toggle_mute(part_id, track_id, muted)
signal set_beats(part_id, track_id, beats)

var _client = WebSocketClient.new()
var _is_connected = false

var PARAM_WS_SERVER_URL: String
var get_main_data: FuncRef

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
	var dict = lobby.to_dict()
	var msg = {
		"intent" : "lobby:update_parts",
		"parts" : dict["parts"]
	}
	_send_data(JSON.print(msg))
func notify_BPM(part_id: String, value: int):
	var msg = {
		"intent" : "part:change_bpm",
		"part_id" : part_id,
		"bpm" : value
	}
	_send_data(JSON.print(msg))
func notify_bars(part_id: String, value: int):
	var msg = {
		"intent" : "part:change_bars",
		"part_id" : part_id,
		"bars" : value
	}
	_send_data(JSON.print(msg))
func notify_sig_lower(part_id: String, value: int):
	var msg = {
		"intent" : "part:change_sig_lower",
		"part_id" : part_id,
		"sig_lower" : value
	}
	_send_data(JSON.print(msg))
func notify_sig_upper(part_id: String, value: int):
	var msg = {
		"intent" : "part:change_sig_upper",
		"part_id" : part_id,
		"sig_upper" : value
	}
	_send_data(JSON.print(msg))
func notify_add_track(part_id: String, track: Data.Track):
	var msg = {
		"intent" : "part:add_track",
		"part_id" : part_id,
		"track_data" : track
	}
	_send_data(JSON.print(msg))
func notify_remove_track(part_id: String, track_id: String):
	var msg = {
		"intent" : "part:remove_track",
		"part_id" : part_id,
		"track_id" : track_id
	}
	_send_data(JSON.print(msg))
func notify_change_volume(part_id: String, track_id: String, volume: int):
	var msg = {
		"intent" : "track:change_volume",
		"part_id" : part_id,
		"track_id" : track_id,
		"volume" : volume
	}
	_send_data(JSON.print(msg))
func notify_toggle_mute(part_id: String, track_id: String, muted: bool):
	var msg = {
		"intent" : "track:toggle_mute",
		"part_id" : part_id,
		"track_id" : track_id,
		"mute" : muted
	}
	_send_data(JSON.print(msg))
func notify_change_sample(part_id: String, track_id: String, sample_id: int):
	var msg = {
		"intent" : "track:set_sample",
		"part_id" : part_id,
		"track_id" : track_id,
		"sample" : sample_id
	}
	_send_data(JSON.print(msg))
func notify_set_beats(part_id: String, track_id: String, beats: Array):
	var msg = {
		"intent" : "track:set_beats",
		"part_id" : part_id,
		"track_id" : track_id,
		"beats" : beats
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
		print("PARAM_WS_SERVER_URL: ", PARAM_WS_SERVER_URL)

	yield(get_tree(), "idle_frame")
	start_connection()

func get_browser_get_parameter():
	if OS.has_feature("JavaScript"):
		return JavaScript.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("l");
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
				var lobby # : Data.Lobby
				if data_json.get("lobby") == null:
					lobby = Data.Lobby.new()
					lobby.id = "i-am-a-drum-bee"
					# TODO also mock user
					print("lobby:create : Mocking lobby id ", lobby.id)
				else:
					lobby = Data.Lobby.from_dict(data_json.lobby)


				emit_signal("lobby_create", lobby.id)

				notify_update_parts(get_main_data.call_func())
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
				notify_update_parts(get_main_data.call_func())
			"part:add_track":
				emit_signal("add_track", data_json.part_id, data_json.track)
			"part:remove_track":
				emit_signal("remove_track", data_json.part_id, data_json.track_id)
			"part:change_bpm":
				emit_signal("change_BPM", data_json.part_id, data_json.bpm)
			"part:change_bars":
				emit_signal("change_bars", data_json.part_id, data_json.bars)
			"part:change_sig_lower":
				emit_signal("change_sig_lower", data_json.part_id, data_json.sig_lower)
			"part:change_sig_upper":
				emit_signal("change_sig_upper", data_json.part_id, data_json.sig_upper)
			"track:set_sample":
				emit_signal("set_sample", data_json.part_id, data_json.track_id, data_json.sample)
			"track:change_volume":
				emit_signal("change_volume", data_json.part_id, data_json.track_id, data_json.volume)
			"track:toggle_mute":
				emit_signal("toggle_mute", data_json.part_id, data_json.track_id, data_json.mute)
			"track:set_beats":
				emit_signal("set_beats", data_json.part_id, data_json.track_id, data_json.beats)

func _process(delta):
	_client.poll()
