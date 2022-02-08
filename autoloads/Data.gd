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
	var bpm: int = 120 setget _set_bpm
	var bars: int = 2
	var sig_upper: int = 4
	var sig_lower: int = 4
	var time: float = 0
	var time_last: float = -0.00000001
	var tracks: Array = [
	]
	
	func _init():
		_set_bpm(bpm)
		
	var spb # sec per beat
	func _set_bpm(val):
		bpm = val
		spb = 60.0 / bpm

	static func from_dict(dict: Dictionary) -> Part:
		var part = Part.new()
		part.id = dict["id"]
		part._set_bpm(dict["bpm"])
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
	var color_per_beat: Array
	var sample_id: int = 0
	var volume: int = 50
	func _init(part_data):
		var num_beats = part_data.sig_lower * part_data.bars
		beats = []
		for _i in range(num_beats):
			beats.append(false)
		for _i in range(num_beats):
			color_per_beat.append([])
			
	func change_time_sig(part_data: Part):
		var old_size = len(beats)
		var new_size = part_data.sig_lower * part_data.bars
		beats.resize(new_size)
		for i in range(old_size, new_size):
			beats[i] = false
		color_per_beat.resize(new_size)
		for i in range(old_size, new_size):
			color_per_beat[i] = []

	static func from_dict(dict: Dictionary, part: Part) -> Track:
		var track = Track.new(part)
		track.id = dict['id']
		track.muted = dict['muted']
		track.sample_id = dict['sample']
		track.volume = dict['volume']
		track.beats = dict['beats']
		track.color_per_beat = dict['color_per_beat']
		return track

	func to_dict() -> Dictionary:
		var d = {}
		d['id'] = id
		d['muted'] = muted
		d['sample'] = sample_id
		d['volume'] = volume
		d['beats'] = beats
		d['color_per_beat'] = color_per_beat
		return d
		

enum State {
	DISCONNECTED,
	JOINING,
	IN_LOBBY,
}

enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
	DISCONNECTING,
}


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
		for sample_id in Consts.INITIAL_SAMPLES:
			var sample = Consts.SAMPLES[sample_id]
			part.tracks.append(initial_track(part, sample[0], sample_id))
#		part.tracks.append(initial_track(part, "Synth2 c4", 36))
#		part.tracks.append(initial_track(part, "Synth2 a4", 45))
#		part.tracks.append(initial_track(part, "Drum snare", 0))
#		part.tracks.append(initial_track(part, "Drum bass acoustic", 9))
	return part

func initial_track(part: Part, id: String, sample_id: int = 0):
	var track = Track.new(part)
	track.id = id
	track.sample_id = sample_id
	return track
