extends Area

export var dps = 1
export var sleep_time = 1
var timer: Timer
var burst_count: int

# for this to work properly we need to check every somany seconds

func _ready():
	timer = Timer.new() #create new timer obj
	timer.wait_time = sleep_time
	timer.connect("timeout", self, "check_bodies") #on timeout, run the function finish_attack
	timer.one_shot = false
	add_child(timer)

func explode():
	burst_count = 0
	timer.start()
	
func check_bodies():
	if burst_count == $DeathTimer.get_wait_time():
		timer.stop()
		burst_count = 0
		return
	$Particles.emitting = true
	var query = PhysicsShapeQueryParameters.new()
	query.set_transform(global_transform)
	query.set_shape($CollisionShape.shape)
	query.collision_mask = collision_mask
	var space_state = get_world().get_direct_space_state()
	var results = space_state.intersect_shape(query) #max 32 intersections, editable
	for data in results:
		if data.collider.has_method("hurt"):
			data.collider.hurt(dps, global_transform.origin.direction_to(data.collider.global_transform.origin))
		else:
			print("no")
	print("done")
	burst_count += 1
