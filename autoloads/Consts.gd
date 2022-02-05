extends Node

const HTTP_SERVER_URL = "http://localhost:8001/Jambeez-client.html"
#const WS_SERVER_URL = "ws://echo.websocket.events/.ws"
#const WS_SERVER_URL = "ws://localhost:8080/jambeez"
const WS_SERVER_URL = "ws://vps.fuchss.org:8888/jambeez"



const SAMPLES = [
	["Snare Drum", preload("res://assets/samples/drums/snare_drum.wav")],
	["Bass Drum", preload("res://assets/samples/drums/bass_drum.wav")],
	["Cow Bell", preload("res://assets/samples/drums/cow_bell.wav")],
	["Kick", preload("res://assets/samples/drums/kick.wav")]
]

func get_invite_link(lobby_id) -> String:
	return "%s?lobby_id=%s" % [HTTP_SERVER_URL, str(lobby_id)]


func initial_lobby(id: String) -> Dictionary:
	return {
	"id": id,
	"parts": [
		initial_part("Part 1"),
		initial_part("Part 2"),
		initial_part("Part 3"),
	]
}

func initial_part(id: String):
	return {
		"id": id,
		"bpm": 120,
		"bars": 4,
		"sig_upper": 4,
		"sig_lower": 4,
		"tracks": [
			initial_track("Track 1", 0),
			initial_track("Track 2", 1),
			initial_track("Track 3", 2),
			initial_track("Track 4", 3),
		]
	}

func initial_track(id: String, sample_id: int):
	return {
		"id": id,
		"muted": false,
		"sample_id": sample_id,
		"beats": [
			initial_beat(), initial_beat(), initial_beat(), initial_beat(),
			initial_beat(), initial_beat(), initial_beat(), initial_beat(),
			initial_beat(), initial_beat(), initial_beat(), initial_beat(),
			initial_beat(), initial_beat(), initial_beat(), initial_beat(),
		]
	}

func initial_beat():
	return {
		"is_on": false
	}
