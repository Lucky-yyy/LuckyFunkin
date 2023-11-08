extends Label

@onready var main = get_parent()

var data = {
	"text": "",
	"offset": 0,
	"order": 0
}

func _process(delta):
	text = data.text
	position = Vector2(
		((main.option_offset + data.offset) / 4),
		main.option_offset + data.offset + 38
	)
	
	var brightness = 0.5
	
	if data.order == main.select:
		brightness = 1.0
	
	modulate.v = lerp(modulate.v,brightness,10.0 * delta)
