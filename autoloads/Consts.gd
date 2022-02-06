extends Node

const HTTP_SERVER_URL = "jambeez.github.io"
#const WS_SERVER_URL = "ws://echo.websocket.events/.ws"
#const WS_SERVER_URL = "ws://localhost:8080/jambeez"
# url encoded ws%3A%2F%2Flocalhost%3A8080%2Fjambeez
#const WS_SERVER_URL = "ws://vps.fuchss.org:8888/jambeez"
var WS_SERVER_URL = "wss://ci.fuchss.org/jambeez"
# url encoded wss%3A%2F%2Fci.fuchss.org%2Fjambeez

var PARAM_LOBBY_ID = null
const JOIN_DEBUG_SESSION = false
var PARAM_AUTO_CONNECT = true
var PARAM_AUTO_SHARE = true

var beat_style_normal:StyleBoxTexture
var beat_style_active:StyleBoxTexture

func _ready():
	if JOIN_DEBUG_SESSION and OS.is_debug_build():
		PARAM_LOBBY_ID = "DEBUG"
		print("Debug: Set param url to ", PARAM_LOBBY_ID)
	else:
		PARAM_LOBBY_ID = get_browser_get_parameter("l")
		print("Read lobby join id from url: ", PARAM_LOBBY_ID)
	
	if get_browser_get_parameter("no_autoconnect") == "t":
		PARAM_AUTO_CONNECT = false
		print("No automatic connectin requested by url params")

	if get_browser_get_parameter("no_autoshare") == "t":
		PARAM_AUTO_CONNECT = false
		print("No automatic sharing requested by url params")

	var param_ws_server = get_browser_get_parameter("ws_server")
	if param_ws_server != null:
		WS_SERVER_URL = param_ws_server
		print("Read ws server address from url: ", WS_SERVER_URL)
	
	var texture = preload("res://assets/img/theme.png")
	var margin = 12
	beat_style_normal = StyleBoxTexture.new()
	beat_style_normal.texture = texture
	beat_style_normal.region_rect = Rect2(65, 1, 2*margin+1, 2*margin+1)
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
	["Drum snare", preload("res://assets/samples/drums/snare_drum.wav")],
	["Drum bass bad", preload("res://assets/samples/drums/bass_drum.wav")],
	["Drum cow bell", preload("res://assets/samples/drums/cow_bell.wav")],
	["Drum kick", preload("res://assets/samples/drums/kick.wav")],
	["Drum bass rustle", preload("res://assets/samples/drums/bass_drum2.wav")],
	["Drum bass flick", preload("res://assets/samples/drums/bass_drum3.wav")],
	["Drum bass synth", preload("res://assets/samples/drums/bass_drum4.wav")],
	["Drum bass heavy", preload("res://assets/samples/drums/bass_drum5.wav")],
	["Drum bass bamboo", preload("res://assets/samples/drums/bass_drum6.wav")],
	["Drum bass acoustic", preload("res://assets/samples/drums/bass_drum7.wav")],
	
	["Synth c3", preload("res://assets/samples/synth/c_3.wav")],
	["Synth c#3", preload("res://assets/samples/synth/c_sharp_3.wav")],
	["Synth d3", preload("res://assets/samples/synth/d_3.wav")],
	["Synth d#3", preload("res://assets/samples/synth/d_sharp_3.wav")],
	["Synth e3", preload("res://assets/samples/synth/e_3.wav")],
	["Synth f3", preload("res://assets/samples/synth/f_3.wav")],
	["Synth f#3", preload("res://assets/samples/synth/f_sharp_3.wav")],
	["Synth g3", preload("res://assets/samples/synth/g_3.wav")],
	["Synth g#3", preload("res://assets/samples/synth/g_sharp_3.wav")],
	["Synth a3", preload("res://assets/samples/synth/a_3.wav")],
	["Synth a#3", preload("res://assets/samples/synth/a_sharp_3.wav")],
	["Synth b3", preload("res://assets/samples/synth/b_3.wav")],
	["Synth c4", preload("res://assets/samples/synth/c_4.wav")],
	
	["Piano c3", preload("res://assets/samples/piano/c_3.wav")],
	["Piano c#3", preload("res://assets/samples/piano/c_sharp_3.wav")],
	["Piano d3", preload("res://assets/samples/piano/d_3.wav")],
	["Piano d#3", preload("res://assets/samples/piano/d_sharp_3.wav")],
	["Piano e3", preload("res://assets/samples/piano/e_3.wav")],
	["Piano f3", preload("res://assets/samples/piano/f_3.wav")],
	["Piano f#3", preload("res://assets/samples/piano/f_sharp_3.wav")],
	["Piano g3", preload("res://assets/samples/piano/g_3.wav")],
	["Piano g#3", preload("res://assets/samples/piano/g_sharp_3.wav")],
	["Piano a3", preload("res://assets/samples/piano/a_3.wav")],
	["Piano a#3", preload("res://assets/samples/piano/a_sharp_3.wav")],
	["Piano b3", preload("res://assets/samples/piano/b_3.wav")],
	["Piano c4", preload("res://assets/samples/piano/c_4.wav")],
	
	["Synth2 c4", preload("res://assets/samples/synth2/c_4.wav")],
	["Synth2 c#4", preload("res://assets/samples/synth2/c_sharp_4.wav")],
	["Synth2 d4", preload("res://assets/samples/synth2/d_4.wav")],
	["Synth2 d#4", preload("res://assets/samples/synth2/d_sharp_4.wav")],
	["Synth2 e4", preload("res://assets/samples/synth2/e_4.wav")],
	["Synth2 f4", preload("res://assets/samples/synth2/f_4.wav")],
	["Synth2 f#4", preload("res://assets/samples/synth2/f_sharp_4.wav")],
	["Synth2 g4", preload("res://assets/samples/synth2/g_4.wav")],
	["Synth2 g#4", preload("res://assets/samples/synth2/g_sharp_4.wav")],
	["Synth2 a4", preload("res://assets/samples/synth2/a_4.wav")],
	["Synth2 a#4", preload("res://assets/samples/synth2/a_sharp_4.wav")],
	["Synth2 b4", preload("res://assets/samples/synth2/b_4.wav")],
	["Synth2 c5", preload("res://assets/samples/synth2/c_5.wav")],
	["Synth2 c#5", preload("res://assets/samples/synth2/c_sharp_5.wav")],
	["Synth2 d5", preload("res://assets/samples/synth2/d_5.wav")],
	["Synth2 d#5", preload("res://assets/samples/synth2/d_sharp_5.wav")],
	["Synth2 e5", preload("res://assets/samples/synth2/e_5.wav")],
	["Synth2 f5", preload("res://assets/samples/synth2/f_5.wav")],
	["Synth2 f#5", preload("res://assets/samples/synth2/f_sharp_5.wav")],
	["Synth2 g5", preload("res://assets/samples/synth2/g_5.wav")],
	["Synth2 g#5", preload("res://assets/samples/synth2/g_sharp_5.wav")],
	["Synth2 a5", preload("res://assets/samples/synth2/a_5.wav")],
	["Synth2 a#5", preload("res://assets/samples/synth2/a_sharp_5.wav")],
	["Synth2 b5", preload("res://assets/samples/synth2/b_5.wav")],
	["Synth2 c6", preload("res://assets/samples/synth2/c_6.wav")],
]

# parse a invite linke smart
static func lobby_id_from_invite(input: String):
	var regex = RegEx.new()
	regex.compile('[\\?\\&]l=([^&]*)')
	var result = regex.search(input)
	if result:
		return result.get_string(1)
	
	var clean = input.strip_edges()
	var split = clean.split("_")
	if len(split) == 3:
		return clean
	
	split = clean.split(" ")
	if len(split) == 3:
		return split.join("_")
	
	return null


#	Consts.lobby_id_from_invite("https://jambeez.github.io/?l=Djembe_Xiao_Txistu")
#	Consts.lobby_id_from_invite("Djembe_Xiao_Txistu")
#	Consts.lobby_id_from_invite("Djembe Xiao Txistu")

static func to_invite_link(lobby_id: String) -> String:
	return "%s?l=%s" % [HTTP_SERVER_URL, lobby_id]

func get_browser_get_parameter(id: String):
	if OS.has_feature("JavaScript"):
		return JavaScript.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("%s");
		""" % id) # TODO prevent js injection
	return null
