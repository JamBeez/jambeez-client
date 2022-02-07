extends Control

export (NodePath) var path_link_edit
onready var node_link_edit = get_node(path_link_edit)

export (NodePath) var path_button
onready var node_button = get_node(path_button)

signal join(lobby_id)

export(Data.State) var state = Data.State.DISCONNECTED setget set_state, get_state

func _ready():
	set_state(Data.State.DISCONNECTED)
	$InvatationConfirm.hide()

func set_state(val, link = null):
	match val:
		Data.State.DISCONNECTED:
			var text = "paste invite link here"
			if link != null:
				text = link
			elif Consts.lobby_id_from_invite(OS.clipboard) != null:
				text = OS.clipboard
			node_link_edit.text = text
			node_link_edit.editable = true
			node_link_edit.clear_button_enabled = true
			node_button.text = "Join"
			node_button.disabled = false
		Data.State.JOINING:
			node_link_edit.editable = false
			node_button.text = "Joining..."
			node_button.disabled = true
		Data.State.IN_LOBBY:
			node_link_edit.text = link
			node_link_edit.editable = false
			node_button.text = "Copy"
			node_button.disabled = false
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
	node_link_edit.clear_button_enabled = Consts.lobby_id_from_invite(new_text) == null

func _text_entered(new_text):
	node_button.set_pressed(true)

func _on_Button_pressed():
	match state:
		Data.State.DISCONNECTED:
			var text = Consts.lobby_id_from_invite(node_link_edit.text)
			if text == null:
				text = node_link_edit.text
			node_link_edit.text = text
			emit_signal("join", text)
		Data.State.IN_LOBBY:
			OS.clipboard = node_link_edit.text
			$InvatationConfirm.show()
			$Timer.start(3)


func _on_Timer_timeout():
	$InvatationConfirm.hide()
