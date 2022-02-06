extends Control


signal join(lobby_id)

export(Data.State) var state = Data.State.DISCONNECTED setget set_state, get_state

func _ready():
	set_state(Data.State.DISCONNECTED)

func set_state(val, link = null):
	match val:
		Data.State.DISCONNECTED:
			var text = "paste invite link here"
			if link != null:
				text = link
			elif Consts.lobby_id_from_invite(OS.clipboard) != null:
				text = OS.clipboard
			$LinkEdit.text = text
			$LinkEdit.editable = true
			$LinkEdit.clear_button_enabled = true
			$Button.text = "Join"
			$Button.disabled = false
		Data.State.JOINING:
			$LinkEdit.editable = false
			$Button.text = "Joining..."
			$Button.disabled = true
		Data.State.IN_LOBBY:
			$LinkEdit.text = link
			$LinkEdit.editable = false
			$Button.text = "Copy"
			$Button.disabled = false
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
	$LinkEdit.clear_button_enabled = Consts.lobby_id_from_invite(new_text) == null

func _text_entered(new_text):
	$Button.set_pressed(true)

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
			$InvatationPopup.popup()
