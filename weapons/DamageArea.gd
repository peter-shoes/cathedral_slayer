extends Area


var bodies_to_exclude : Array = []
export var damage = 5

func fire():
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and !bodies_to_exclude.has(body):
			body.hurt(damage, global_transform.origin.direction_to(body.global_transform.origin))
			
func set_damage(dmg: int):
	damage = dmg
	
func set_bodies_to_exclude(bte):
	bodies_to_exclude = bte
