extends Node

const HTTP_SERVER_URL = "http://localhost:8001/Jambeez-client.html"
const WS_SERVER_URL = "ws://echo.websocket.events/.ws"
#const WS_SERVER_URL = "ws://localhost:8000/jambeez"

func get_invite_link(lobby_id) -> String:
	return "%s?lobby_id=%s" % [HTTP_SERVER_URL, str(lobby_id)]
