extends Control
onready var crosshair = $CrossHair
onready var mana_bar = $ManaBar

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(mana_bar.get_value())
	update_mana_bar(50)
	print(mana_bar.get_value())
	pass # Replace with function body.

func update_mana_bar(v: int):
	mana_bar.set_value(v)
	print(mana_bar.get_value())
