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
		for t in dict['parts']:
			var part = Part.from_dict(t)
			lobby.parts.append(part)
		return lobby

class User:
	var id: String
	var alias: String
	
	static func from_dict(dict: Dictionary) -> User:
		var user = User.new()
		user.id = dict['id']
		user.alias = "Alias" # dict['alias'] TODO
		return user

class Track:
	var id: String
	var muted: bool
	var beats: Array
	var sample_id: int = 0
	func _init(part_data):
		var num_beats = part_data.sig_lower * part_data.bars
		beats = []
		for i in range(num_beats):
			beats.append(false)
			
	func from_dict(dict: Dictionary, part: Part) -> Track:
		var track = Track.new(part)
		track.muted = dict['muted']
		track.sample_id = dict['sample_id']
		# TODO init read beats from dict
		# track.beats
		return track

class Part:
	var id: String
	var bpm: int = 120
	var bars: int = 2
	var sig_upper: int = 4
	var sig_lower: int = 4
	var time: float = 0
	var time_last: float = -0.00000001
	var tracks: Array = [
		Track.new(self),
		Track.new(self),
		Track.new(self)
	]
	
	func from_dict(dict: Dictionary) -> Part:
		var part = Part.new()
		part.id = dict["id"]
		part.bpm = dict["bpm"]
		part.bars = dict["bars"]
		part.sig_upper = dict["sig_upper"]
		part.sig_lower = dict["sig_lower"]
		# TODO sync timing
		#part.time = dict["time"]
		#part.time_last = dict["time_last"]
		for t in dict["tracks"]:
			var track = Track.from_dict(t)
			part.tracks.append(track)
		return part
