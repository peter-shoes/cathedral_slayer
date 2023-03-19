extends Spatial

signal dead
signal hurt
signal healed
signal health_changed
signal gibbed

export var max_health = 100
var cur_health = 1

onready var marker = load("res://effects/HitMarker.tscn")
onready var gui = get_parent().get_node("Camera/GUI")

var gib_at = -10

func _ready():
	init() #making sure the init is called on the ready, this doesn't hurt because this specific init can be called twice
	
func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)
	if gui:
		gui.set_max_health(max_health)
	
func hurt(damage: int, dir: Vector3, damage_type="normal"):
	#TODO possible damage type differences?
	if cur_health <= 0:
		return #do nothing, we're dead
	cur_health -= damage
	if gui:
		gui.update_health_pts(cur_health)
	if cur_health <= gib_at:
		pass #TODO make gib spawner code
		emit_signal("gibbed")
		print('gibbed')
	if cur_health <=0:
		emit_signal("dead")
		print('dead')
	else:
		emit_signal("hurt")
	emit_signal("health_changed", cur_health)
	print('hurt ', damage, ' current health', cur_health)
	
	if !gui:
		var mkr = marker.instance()
		mkr.translation = get_parent().translation
		mkr.translation.y +=2
		get_tree().get_root().add_child(mkr)
		mkr.get_children()[-1].set_emitting(true)
	
func heal(amount: int):
	if cur_health <=0:
		return #do nothing, we're dead
	cur_health += amount
	if gui:
		gui.update_health_pts(cur_health)
	if cur_health > max_health:
		cur_health = max_health
	emit_signal("healed")
	emit_signal("health_changed", cur_health)
