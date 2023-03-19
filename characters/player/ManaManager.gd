extends Spatial

export var max_mana = 100
var current_mana = 0

onready var gui = get_parent().get_node("Camera/GUI")

# Called when the node enters the scene tree for the first time.
func _ready():
	current_mana = max_mana
	gui.set_max_mana(max_mana)

func spend_mana(p: int):
	if current_mana - p >= 0:
		current_mana -= p
		gui.update_mana_pts(current_mana)
		return true
	else:
		return false
	
func add_mana(p: int):
	if current_mana + p <= max_mana:
		current_mana += p
		gui.update_mana_pts(current_mana)
		return true
	else:
		return false
		


