extends Node2D

var song_name = "senpai"
var song_speed = 2.4
var note_skin = "default"

var input = [KEY_A,KEY_S,KEY_K,KEY_L]
var downscroll = true

func _ready():
	chart = get_node("HUD/Chart")
	discord_sdk.details = "Playing: " + song_name
	discord_sdk.refresh()
	if downscroll:
		$HUD/Chart/Notes/P1.position.y = -$HUD/Chart/Notes/P1.position.y
		$HUD/Chart/Notes/P2.position.y = -$HUD/Chart/Notes/P2.position.y

var song_time = 0
var chart
