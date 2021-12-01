extends Sprite3D

onready var healthbar2D := $Viewport/HealthBar2D

var bar_red = preload("res://Assets/Healthbar/barHorizontal_red.png")
var bar_green = preload("res://Assets/Healthbar/barHorizontal_green.png")
var bar_yellow = preload("res://Assets/Healthbar/barHorizontal_yellow.png")

func _ready():
	texture = $Viewport.get_texture()
	healthbar2D.max_value = get_parent().maxHealth

func setMaxValue(value):
	healthbar2D.max_value = value

func updateHealthbar(value):
	healthbar2D.texture_progress = bar_green
	if value < healthbar2D.max_value * 0.7:
		healthbar2D.texture_progress = bar_yellow
	if value < healthbar2D.max_value * 0.35:
		healthbar2D.texture_progress = bar_red
	if value < healthbar2D.max_value:
		show()
	healthbar2D.value = value
