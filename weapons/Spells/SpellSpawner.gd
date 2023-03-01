extends Spatial

var spell = preload("res://weapons/Spells/Spell.tscn")
var damage = 1
var bodies_to_exclude = []
var current_mana_cost = 5


func set_damage(_damage: int):
	damage = _damage
	
func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude
	
func fire():
	var spell_inst = spell.instance()
	#spell_inst.set_bodies_to_exclude(bodies_to_exclude)
	get_tree().get_root().add_child(spell_inst)
	spell_inst.global_transform = global_transform
	#spell_inst.impact_damage = damage

func get_current_mana_cost():
	return current_mana_cost
