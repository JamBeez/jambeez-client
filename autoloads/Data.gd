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
		#print(dict['parts'])
		for t in dict['parts']:
			var part = Part.from_dict(t)
			lobby.parts.append(part)
		return lobby

	func to_dict() -> Dictionary:
		var d = {}
		d['id'] = id
		d['users'] = []
		for u in users:
			var user = u.to_dict()
			d["users"].append(user)
		d["parts"] = []
		for p in parts:
			var part = p.to_dict()
			d["parts"].append(part)
		return d

class User:
	var id: String
	var alias: String

	static func from_dict(dict: Dictionary) -> User:
		var user = User.new()
		user.id = dict['id']
		user.alias = "Alias" # dict['alias'] TODO
		return user

	func to_dict() -> Dictionary:
		var d = {}
		d['id'] = id
		d['alias'] = alias
		return d

class Part:
	var id: String
	var bpm: int = 120
	var bars: int = 2
	var sig_upper: int = 4
	var sig_lower: int = 4
	var time: float = 0
	var time_last: float = -0.00000001
	var tracks: Array = [
	]

	static func from_dict(dict: Dictionary) -> Part:
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
			var track = Track.from_dict(t, part)
			part.tracks.append(track)
		return part

	func to_dict() -> Dictionary:
		var d = {}
		d["id"] = id
		d["bpm"] = bpm
		d["bars"] = bars
		d["sig_upper"] = sig_upper
		d["sig_lower"] = sig_lower
		d["time"] = time
		d["time_last"] = time_last
		d["tracks"] = []
		for t in tracks:
			d["tracks"].append(t.to_dict())
		return d

class Track:
	var id: String
	var muted: bool
	var beats: Array
	var sample_id: int = 0
	var volume: int = 50
	func _init(part_data):
		var num_beats = part_data.sig_lower * part_data.bars
		beats = []
		for _i in range(num_beats):
			beats.append(false)

	static func from_dict(dict: Dictionary, part: Part) -> Track:
		var track = Track.new(part)
		track.id = dict['id']
		track.muted = dict['muted']
		track.sample_id = dict['sample']
		track.volume = dict['volume']
		# TODO init read beats from dict
		# track.beats
		return track

	func to_dict() -> Dictionary:
		var d = {}
		d['id'] = id
		d['muted'] = muted
		d['sample'] = sample_id
		d['volume'] = volume
		# TODO save beats
		# track.beats
		return d


var initial_state: Lobby = initial_lobby("i-am-a-jam-bee")

func initial_lobby(id: String) -> Lobby:
	var lobby = Lobby.new()
	lobby.id = id
	lobby.users = []
	lobby.parts = [
		initial_part("Part 1", true),
		initial_part("Part 2"),
		initial_part("Part 3"),
	]
	return lobby

func initial_part(id: String, with_tracks: bool = false) -> Part:
	var part = Part.new()
	part.id = id
	if with_tracks:
		part.tracks.append(initial_track(part, "Cow Bell", 2))
		part.tracks.append(initial_track(part, "Kick", 3))
		part.tracks.append(initial_track(part, "Snare Drum", 0))
		part.tracks.append(initial_track(part, "Bass Drum", 1))
	return part

func initial_track(part: Part, id: String, sample_id: int = 0):
	var track = Track.new(part)
	track.id = id
	track.sample_id = sample_id
	return track
