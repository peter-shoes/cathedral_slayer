extends Control
onready var crosshair = $CrossHair
onready var mana_bar = $ManaBar
onready var health_bar = $HealthBar
onready var stamina_bar = $StaminaBar

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var max_mana


# Called when the node enters the scene tree for the first time.
func _ready():
	mana_bar.set_value(100)
	health_bar.set_value(100)
	stamina_bar.set_value(100)
	pass
	#update_mana_bar(mana_manager.get_max_mana())

func update_mana_pts(p: int):
	var mana_percent = float(p)/float(max_mana)
	print(mana_percent)
	
	mana_bar.set_value(mana_percent*100)

func update_mana_raw(v: int):
	mana_bar.set_value(v)

func set_max_mana(v: int):
	max_mana = v
