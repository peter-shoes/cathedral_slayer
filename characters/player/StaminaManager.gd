extends Spatial

export var max_stamina = 100
var current_stamina = 0

onready var gui = get_parent().get_node("Camera/GUI")


# Called when the node enters the scene tree for the first time.
func _ready():
	current_stamina = max_stamina
	gui.set_max_stamina(max_stamina)

func spend_stamina(p: int):
	if current_stamina - p >= 0:
		current_stamina -= p
	gui.update_stamina_pts(current_stamina)
	
func add_stamina(p: int):
	if current_stamina + p <= max_stamina:
		current_stamina += p
	gui.update_stamina_pts(current_stamina)
		


