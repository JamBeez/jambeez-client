extends Node2D

func _ready():
	Communicator.connect("connection_state_changed", self, "_on_Communicator_connection_state_changed")

func _on_Communicator_connection_state_changed(is_connected):
	$CanvasLayer/MarginContainer/VBoxContainer/Header/HBoxContainer/LabelConnectionState.text = "Connected" if is_connected else "Disconnected"
