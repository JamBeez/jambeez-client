extends Node

const HTTP_SERVER_URL = "https://jambeez.github.io"
#const WS_SERVER_URL = "ws://echo.websocket.events/.ws"
#const WS_SERVER_URL = "ws://localhost:8080/jambeez"
#const WS_SERVER_URL = "ws://vps.fuchss.org:8888/jambeez"
const WS_SERVER_URL = "wss://ci.fuchss.org/jambeez"



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
			url.searchParams.get("l");
		""")
	return null
