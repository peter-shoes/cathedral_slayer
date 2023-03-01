extends Spatial

signal mana_restored
signal mana_changed

export var max_mana = 100
var cur_mana = 1

func _ready():
	init() #making sure the init is called on the ready, this doesn't hurt because this specific init can be called twice
	
func init():
	cur_mana = max_mana
	emit_signal("mana_changed", cur_mana)
	
func mana_spend(amt: int):
	if cur_mana <= 0:
		return #do nothing, we're dead
	cur_mana -= amt
	if cur_mana <=0:
		emit_signal("dead")
		print('dead')
	else:
		emit_signal("hurt")
	emit_signal("mana_changed", cur_mana)
	
func mana_restore(amount: int):
	if cur_mana <=0:
		return #do nothing, we're dead
	cur_mana += amount
	if cur_mana > max_mana:
		cur_mana = max_mana
	emit_signal("mana_restored")
	emit_signal("mana_changed", cur_mana)
