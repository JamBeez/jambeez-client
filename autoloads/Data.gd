extends Node

class Lobby:
	var id: String
	var users: Array = [] # Main.UserData
	var parts: Array = [] # Part.PartData
	
	static func from_dict(dict: Dictionary) -> Lobby:
		var lobby = Lobby.new()
		lobby.id = dict['id']
		for u in dict['users']:
			var user = User.from_dict(u)
			lobby.users.append(user)
		for t in dict['tracks']:
			var track = Track.from_dict(t)
			lobby.tracks.append(track)
		dict2inst(dict)
		
		return lobby

class User:
	var id: String
	var alias: String

class Track:
	var id: String
	var muted: bool
	var beats: Array
	var sample: Resource = preload("res://assets/samples/drums/snare_drum.wav")
	func _init(part_data):
		var num_beats = part_data.sig_lower * part_data.bars
		beats = []
		for i in range(num_beats):
			beats.append(false)

class Part:
	var time: float = 0
	var time_last: float = -0.00000001
	var id: String
	var bpm: int = 120
	var bars: int = 2
	var sig_upper: int = 4
	var sig_lower: int = 4
	var tracks: Array = [
		Data.Track.new(self),
		Data.Track.new(self),
		Data.Track.new(self)
	]
