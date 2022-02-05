extends Node

const HTTP_SERVER_URL = "http://url.de"
const WS_SERVER_URL = "ws://echo.websocket.events/.ws"

func get_invite_link(lobby_id) -> String:
	return "%s/%s" % [HTTP_SERVER_URL, str(lobby_id)]
