extends Node

const HTTP_SERVER_URL = "https://jambeez.github.io"
#const WS_SERVER_URL = "ws://echo.websocket.events/.ws"
#const WS_SERVER_URL = "ws://localhost:8080/jambeez"
# url encoded ws%3A%2F%2Flocalhost%3A8080%2Fjambeez
#const WS_SERVER_URL = "ws://vps.fuchss.org:8888/jambeez"
var WS_SERVER_URL = "wss://ci.fuchss.org/jambeez"
# url encoded wss%3A%2F%2Fci.fuchss.org%2Fjambeez

var PARAM_LOBBY_ID = null
const JOIN_DEBUG_SESSION = false

var beat_style_normal:StyleBoxTexture
var beat_style_active:StyleBoxTexture

func _ready():
	if JOIN_DEBUG_SESSION and OS.is_debug_build():
		PARAM_LOBBY_ID = "DEBUG"
		print("Debug: Set param url to ", PARAM_LOBBY_ID)
	else:
		PARAM_LOBBY_ID = get_browser_get_parameter("l")
		print("Read lobby join id from url: ", PARAM_LOBBY_ID)

	var param_ws_server = get_browser_get_parameter("ws_server")
	if param_ws_server != null:
		WS_SERVER_URL = param_ws_server
		print("Read ws server address from url: ", WS_SERVER_URL)
	
	var texture = preload("res://assets/img/theme.png")
	var margin = 12
	beat_style_normal = StyleBoxTexture.new()
	beat_style_normal.texture = texture
	beat_style_normal.region_rect = Rect2(9, 1, 2*margin+1, 2*margin+1)
	beat_style_normal.margin_left = margin
	beat_style_normal.margin_right = margin
	beat_style_normal.margin_top = margin
	beat_style_normal.margin_bottom = margin
	beat_style_active = StyleBoxTexture.new()
	beat_style_active.texture = texture
	beat_style_active.region_rect = Rect2(93, 1, 2*margin+1, 2*margin+1)
	beat_style_active.margin_left = margin
	beat_style_active.margin_right = margin
	beat_style_active.margin_top = margin
	beat_style_active.margin_bottom = margin

const SAMPLES = [
	["Snare Drum", preload("res://assets/samples/drums/snare_drum.wav")],
	["Bass Drum", preload("res://assets/samples/drums/bass_drum.wav")],
	["Cow Bell", preload("res://assets/samples/drums/cow_bell.wav")],
	["Kick", preload("res://assets/samples/drums/kick.wav")],
	["c_3", preload("res://assets/samples/synth/c_3.wav")],
	["c_sharp_3", preload("res://assets/samples/synth/c_sharp_3.wav")],
	["d_3", preload("res://assets/samples/synth/d_3.wav")],
	["d_sharp_3", preload("res://assets/samples/synth/d_sharp_3.wav")],
	["e_3", preload("res://assets/samples/synth/e_3.wav")],
	["f_3", preload("res://assets/samples/synth/f_3.wav")],
	["f_sharp_3", preload("res://assets/samples/synth/f_sharp_3.wav")],
	["g_3", preload("res://assets/samples/synth/g_3.wav")],
	["g_sharp_3", preload("res://assets/samples/synth/g_sharp_3.wav")],
	["a_3", preload("res://assets/samples/synth/a_3.wav")],
	["a_sharp_3", preload("res://assets/samples/synth/a_sharp_3.wav")],
	["b_3", preload("res://assets/samples/synth/b_3.wav")],
	["c_4", preload("res://assets/samples/synth/c_4.wav")],
	
	["c_3", preload("res://assets/samples/piano/c_3.wav")],
	["c_sharp_3", preload("res://assets/samples/piano/c_sharp_3.wav")],
	["d_3", preload("res://assets/samples/piano/d_3.wav")],
	["d_sharp_3", preload("res://assets/samples/piano/d_sharp_3.wav")],
	["e_3", preload("res://assets/samples/piano/e_3.wav")],
	["f_3", preload("res://assets/samples/piano/f_3.wav")],
	["f_sharp_3", preload("res://assets/samples/piano/f_sharp_3.wav")],
	["g_3", preload("res://assets/samples/piano/g_3.wav")],
	["g_sharp_3", preload("res://assets/samples/piano/g_sharp_3.wav")],
	["a_3", preload("res://assets/samples/piano/a_3.wav")],
	["a_sharp_3", preload("res://assets/samples/piano/a_sharp_3.wav")],
	["b_3", preload("res://assets/samples/piano/b_3.wav")],
	["c_4", preload("res://assets/samples/piano/c_4.wav")],
]

func get_invite_link(lobby_id) -> String:
	return "%s?l=%s" % [HTTP_SERVER_URL, str(lobby_id)]

func get_browser_get_parameter(id: String):
	if OS.has_feature("JavaScript"):
		return JavaScript.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("%s");
		""" % id) # TODO prevent js injection
	return null
