extends Node

signal section_changed

signal second_beat
signal first_beat

# Properties
var bpm = 120
var sections : Array = []
var current_section = -1
var beat_count = 0

func initialize():
	current_section = -1
	bpm = get_parent().chart.info.bpm

func _process(_delta):
	var chart = get_parent().chart
	var audio_player = get_parent().get_node_or_null("Instrumental")

	if audio_player.playing:
		var section_duration = 2400 / (bpm * 0.01)
		var audio_position = get_parent().song_time

		if current_section == -1:
			sections.append(0)
			current_section += 1
			emit_signal("section_changed",chart.sections[current_section])

		if audio_position > sections[current_section] + (section_duration / 4) * beat_count:
			emit_signal("first_beat")
			if beat_count == 2:
				emit_signal("second_beat")
			beat_count += 1

		if audio_position > sections[current_section] + section_duration:
			beat_count = 0
			sections.append(sections[current_section] + section_duration)
			current_section += 1
			if current_section < chart.sections.size():
				process_section(chart.sections[current_section])
				emit_signal("second_beat")
				emit_signal("section_changed",chart.sections[current_section]) 

func process_section(section_info):
	var changeBPM = section_info.has("changeBPM") and section_info["changeBPM"]

	# Example: Change BPM if required
	if changeBPM:
		bpm = section_info["bpm"]
