extends Node

const HTTP_SERVER_URL = "http://localhost:8001/Jambeez-client.html"
#const WS_SERVER_URL = "ws://echo.websocket.events/.ws"
const WS_SERVER_URL = "ws://localhost:8080/jambeez"

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
			initial_track("Track 1")
		]
	}

func initial_track(id: String):
	return {
		"id": id,
		"muted": false,
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
