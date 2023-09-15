extends Node

var song_time = -2000
var song_data = {
	"name":null,
	"speed":1.0,
}

var chart = {
	"notes": [],
	"sections": [],
	"info": {},
	"psych_events": []
}

func _load(song_name,note_skin):
	song_data.name = song_name
	$Notes.load_notes_texture(note_skin)
	load_audio()
	load_chart()
	song_data.speed = chart.info.speed * 1.0
	

func start_song():
	$Timeline.initialize()
	$Instrumental.play(0)
	$Voices.play(0)
	discord_sdk.start_timestamp = int(Time.get_unix_time_from_system())
	discord_sdk.end_timestamp = int(Time.get_unix_time_from_system()) + $Instrumental.stream.get_length()
	discord_sdk.refresh()

var last_update_time = 0.0

var play = true

func _process(delta):
	$Label.text = "song_time: " + str(song_time) + "\n"
	
	if $Instrumental.playing:
		var playback_adjusted_time = ($Instrumental.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()) * 1000.0

		var time_difference = playback_adjusted_time - song_time
		var max_adjustment = delta * 1000.0 * $Instrumental.pitch_scale
		var adjustment = clamp(time_difference, -max_adjustment, max_adjustment)

		if abs(adjustment) > 0.01:
			song_time += adjustment
			process_notes()

			var delay = int(playback_adjusted_time) - int(song_time)
			if delay > 40:
				song_time = playback_adjusted_time

			$Label.text += "delay: " + str(delay)
	elif song_time < 0:
		song_time += delta * 1000.0 * $Instrumental.pitch_scale
		process_notes()
	elif play:
		play = false
		start_song()

var count = 0
var note = preload("res://src/Scenes/Game/chart/note.tscn")

var NoteOrder = [[],[],[],[],[],[],[],[]]

var def_note_nodes = [
	"Notes/P1/Left",
	"Notes/P1/Down",
	"Notes/P1/Up",
	"Notes/P1/Right",
	
	"Notes/P2/Left",
	"Notes/P2/Down",
	"Notes/P2/Up",
	"Notes/P2/Right"
]

var def_notes = [
	"Left",
	"Down",
	"Up",
	"Right",
]

func process_notes():
	var inputs = get_tree().get_current_scene().input
	if chart.notes.size() > count:
		if chart.notes[count][0] < song_time + 2000:
			var instance = note.instantiate()
			get_node(def_note_nodes[chart.notes[count][1]]).add_child(instance)
			instance.data = chart.notes[count]
			instance.note_position = chart.notes[count][0]
			if chart.notes[count][1] > 3:
				instance.note_data.bot = true
			else:
				NoteOrder[chart.notes[count][1]].append(chart.notes[count][0])
				instance.note_data.bot = false
				instance.note_data.input = inputs[chart.notes[count][1]]
			instance.texture = $Notes.data[def_notes[int(chart.notes[count][1]) % 4]]["Note"]["texture"][0]
			instance.get_node("Sustain").texture = $Notes.data[def_notes[int(chart.notes[count][1]) % 4]]["Note_Long"]["texture"][0]
			instance.get_node("Sustain/End").texture = $Notes.data[def_notes[int(chart.notes[count][1]) % 4]]["Note_Long_End"]["texture"][0]
			count += 1

func load_audio():
	var inst_path = "res://assets/songs/" + song_data.name + "/Inst.ogg"
	var voices_path = "res://assets/songs/" + song_data.name + "/Voices.ogg"
	$Instrumental.stream = AudioStreamOggVorbis.load_from_file(inst_path)
	$Voices.stream = AudioStreamOggVorbis.load_from_file(voices_path)

func load_chart():
	var song_path = "res://assets/songs/" + song_data.name + "/" + song_data.name + ".json"

	# Load the JSON data
	var file = FileAccess.open(song_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var chart_data = JSON.parse_string(json_text).song

	# Process and organize notes
	for note_item in chart_data.notes:  # Rename the iterator variable
		var section_notes = note_item.sectionNotes
		var section = note_item
		section.erase("sectionNotes")
		chart.sections.append(section)

		var must_hit_section = note_item.mustHitSection
		for note_data in section_notes:
			if note_data[1] == -1 or note_data[1] > 7:
				continue

			var time = note_data[0]
			var note_type = note_data[1]
			var sustain = note_data[2]
			var misc = 0
			if note_data.size() > 3:
				misc = note_data[3]
				if note_data[3] == "Sword":
					continue

			if !must_hit_section:
				note_type = int(note_type + 4) % 8
			chart.notes.append([time, note_type, sustain, misc])

	chart_data.erase("notes")
	if chart_data.has("events"):
		chart.psych_events = chart_data.events
		chart_data.erase("events")
	chart.info = chart_data
	chart.notes.sort_custom(func(a, b): return a[0] < b[0])

signal char_animation

func notemiss(_order,_type):
	get_parent().get_node("Status").misses += 1
	get_parent().get_node("Status").maxscore += 350

func notehit(_order,_distance,_type):
	get_parent().get_node("Status").maxscore += 350
	if _distance < 45:
		get_parent().get_node("Status").score += 350
	elif _distance < 90:
		get_parent().get_node("Status").score += 200
	elif _distance < 135:
		get_parent().get_node("Status").score += 100
	else:
		get_parent().get_node("Status").score += 50
