extends Node2D

const option_spacing = 72.0
var options = {
	"Gameplay": {
		"Ghost Tapping": ["ghost", BOOLEAN],
		"Scroll": ["scroll", RANGE, ["Up", "Down"]],
		"Opponent Notes": ["opponent_notes", BOOLEAN],
		"Disable Reset": ["disable_reset", BOOLEAN]
	},
	"Audio": {
		"Offset": ["offset",VALUE,[0.0,10.0]]
	},
	"Controls": {
		"Left":null,
		"Down":null,
		"Up":null,
		"Right":null
	},
	"Graphics": {
		"FPS": ["fps",VALUE,[30.0,240.0]],
		"Show FPS": ["show_fps", BOOLEAN]
	},
	"Visuals": {
		"Hide Hud": ["hide_hud", BOOLEAN],
		"Timer Bar": ["timer_bar", BOOLEAN]
	}
}

#------------------------------------------------------------------------

var in_group = false
var group_select = 0
var select = 0

func process_input():
	if in_group:
		var group = options.keys()[group_select]
		if Input.is_action_just_pressed("ui_up"):
			Sound.play("scroll")
			select -= 1
			if select < 0:
				select = options[group].size() - 1
		if Input.is_action_just_pressed("ui_down"):
			Sound.play("scroll")
			select += 1
			if select > options[group].size() - 1:
				select = 0
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			Sound.play("scroll")
			#change variable
		if Input.is_action_just_pressed("ui_cancel"):
			Sound.play("cancel")
			in_group = false
	else:
		if Input.is_action_just_pressed("ui_left"):
			Sound.play("scroll")
			group_select -= 1
			if group_select < 0:
				group_select = options.size() - 1
			create_options(options.keys()[group_select])
		if Input.is_action_just_pressed("ui_right"):
			Sound.play("scroll")
			group_select += 1
			if group_select > options.size() - 1:
				group_select = 0
			create_options(options.keys()[group_select])
		if Input.is_action_just_pressed("ui_accept"):
			Sound.play("confirm")
			in_group = true
			select = 0


#------------------------------------------------------------------------

func _ready():
	RenderingServer.set_default_clear_color(Color(0, 0, 0))
	initalize_bg()
	create_groups()
	create_options(options.keys()[0])

func _process(delta):
	scroll_options(delta)
	scroll_options_group(delta)
	process_input()

#------------------------------------------------------------------------

func initalize_bg():
	var image = Image.new()
	image.load("res://assets/images/Options/bg.png")
	$Background.texture = ImageTexture.create_from_image(image)

#------------------------------------------------------------------------

const group_spacing = 400.0
var group_offset = 286.0

var group_node = preload("res://src/Scenes/Menus/Options/group.tscn")

func scroll_options_group(delta):
	group_offset = lerp(group_offset, 406 - (group_select * group_spacing),10.0 * delta)

func create_groups():
	for option in options.size():
		var instance = group_node.instantiate()
		add_child(instance)
		instance.data = {
			"text": options.keys()[option],
			"offset": group_spacing * option,
			"order": option
		}

#------------------------------------------------------------------------

const spacing = 32.0
var offset = 286.0

var node = preload("res://src/Scenes/Menus/Options/option.tscn")
var nodes = []

func scroll_options(delta):
	offset = lerp(offset, 406 - (select * group_spacing),10.0 * delta)

func create_options(group):
	for option in nodes:
		option.queue_free()
	nodes = []
	
	for option in options[group].size():
		var instance = node.instantiate()
		add_child(instance)
		nodes.append(instance)
		instance.modulate.v = 0.5
		instance.position.y = -240
		instance.data = {
			"text": options[group].keys()[option],
			"offset": spacing * option,
			"order": option
		}

#------------------------------------------------------------------------

enum {
	BOOLEAN,
	PERCENTAGE,
	RANGE,
	VALUE
}
