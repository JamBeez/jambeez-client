extends Control


signal join(lobby_id)

export(Data.State) var state = Data.State.DISCONNECTED setget set_state, get_state

func _ready():
	set_state(Data.State.DISCONNECTED)

func set_state(val: int, link = null):
	match val:
		Data.State.DISCONNECTED:
			var text = OS.clipboard
			$LinkEdit.text = text if Consts.lobby_id_from_invite(text) != null else "paste invite link here"
			$LinkEdit.editable = true
			$LinkEdit.clear_button_enabled = true
			$Button.text = "Join"
		Data.State.IN_LOBBY:
			$LinkEdit.text = link
			$LinkEdit.editable = false
			$LinkEdit.clear_button_enabled = true
			$Button.text = "Copy"
	state = val

func get_state():
	return state
	
#func _input(event):
#	if event is InputEventMouseButton and event.pressed:
##		if event.button_index == BUTTON_LEFT:
##			set_state(State.DISCONNECTED)
#		if event.button_index == BUTTON_RIGHT:
#			set_state(Data.State.IN_LOBBY)
#		elif event.button_index == BUTTON_MIDDLE:
#			set_state(Data.State.DISCONNECTED)


func _text_changed(new_text):
	if new_text == "":
		pass
	print("changed to ", new_text, " from ", $LinkEdit.text)


func _on_Button_pressed():
	match state:
		Data.State.DISCONNECTED:
			var text = Consts.lobby_id_from_invite($LinkEdit.text)
			if text == null:
				text = $LinkEdit.text
			$LinkEdit.text = text
			print(text)
			emit_signal("join", text)
		Data.State.IN_LOBBY:
			OS.clipboard = $LinkEdit.text
