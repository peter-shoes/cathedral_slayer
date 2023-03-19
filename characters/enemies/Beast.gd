extends KinematicBody

onready var character_mover = $CharacterMover
onready var anim_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager
onready var aimer = $AimAtObject
#no parent in this scene, but in the main scene it's parent is the nav mngr
#for that reason, beasts must always be a child of the nav manager or node
onready var nav : Navigation = get_parent()

enum STATES{IDLE, CHASE, ATTACK, DEAD}
var cur_state = STATES.IDLE

var player = null
var path = []

export var sight_angle = 45.0

var turn_speed = 360.0

export var attack_range = 2.0
export var attack_rate = 1.0
var attack_timer: Timer
var can_attack = true

# random walk vars
var initial_pos: Vector3
var walk_pos: Vector3

signal attack

func _ready():
	randomize()

	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is Hitbox:
				child.connect("hurt", self, "hurt")
	health_manager.connect("dead", self, "set_state_dead")
	character_mover.init(self)
	set_state_idle()

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)

func set_state_idle():
	cur_state = STATES.IDLE
	#anim_player.play("idle")

func set_state_chase():
	cur_state = STATES.CHASE
	# the second arg here will do some blending
	anim_player.play("walk_loop")

func set_state_attack():
	cur_state = STATES.ATTACK
	anim_player.play("attack")
	anim_player.stop()

func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("death")
	character_mover.freeze()
	$CollisionShape.disabled = true
	
func process_state_idle(delta):
	if can_see_player():
		set_state_chase()
	else:
		random_walk(delta)
	
func process_state_chase(delta):
	if within_dis_of_player(attack_range) and has_los_player():
		set_state_attack()
	var player_pos = player.global_transform.origin
	var our_pos = global_transform.origin
	# get_simple_path gets local positions
	# in order for this to work globally, our nav mesh must be at 000
	# that way, local and global pos is the same
	path = nav.get_simple_path(our_pos, player_pos)
	var goal_pos = player_pos
	if path.size() > 1:
		goal_pos = path[1]
	
	#vector pointing from our pos to goal pos
	var dir = goal_pos - our_pos
	#make this a 2d vector
	dir.y = 0
	character_mover.set_move_vec(dir)
	face_dir(dir, delta)
	
func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO)
	face_dir(global_transform.origin.direction_to(player.global_transform.origin), delta)
	if can_attack:
		
		if !within_dis_of_player(attack_range) or !can_see_player():
			set_state_chase()

		else:
			start_attack()
	
func process_state_dead(delta):
	#queue_free()
	pass

func hurt(damage: int, dir: Vector3):
	if cur_state == STATES.DEAD:
		return
	if cur_state == STATES.IDLE:
		set_state_chase()
	#anim_player.play("hurt", 0.5) #this doesn't look great
	#anim_player.queue("walk") 
	health_manager.hurt(damage, dir)
	
func start_attack():
	can_attack = false
	anim_player.play("attack")
	attack_timer.start()
	aimer.aim_at_pos(player.global_transform.origin)

func emit_attack_signal():
	emit_signal("attack")
	
func finish_attack():
	can_attack = true
	
func can_see_player():
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < sight_angle and has_los_player()

func has_los_player():
	#we are adding the vec3 to move the pos from the floor
	var our_pos = global_transform.origin + Vector3.UP
	var player_pos = player.global_transform.origin + Vector3.UP
	
	# shooting a raycast from beast to player on env layer
	# we don't see the player if we are between a building
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	if result:
		return false
	return true
	
func face_dir(dir: Vector3, delta):
	var angle_dif = global_transform.basis.z.angle_to(dir)
	#if this is pos, we turn right, otherwise we turn left
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_dif) < deg2rad(turn_speed) * delta:
		# if turning any more will overshoot our goal, just set it to our goal
		rotation.y = atan2(dir.x, dir.z)
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_right
	

func alert(check_los=true):
	if cur_state != STATES.IDLE:
		return
	if check_los and !has_los_player():
		return
	set_state_chase()

func within_dis_of_player(dis: float):
	return global_transform.origin.distance_to(player.global_transform.origin) < dis
	

func random_walk(delta):
	if !initial_pos:
		initial_pos = global_transform.origin
	var our_pos = global_transform.origin
	var goal_pos = null
	if our_pos == initial_pos:
		goal_pos = walk_pos
	elif our_pos == walk_pos:
		goal_pos = initial_pos
	else:
		return

	
		
	# get_simple_path gets local positions
	# in order for this to work globally, our nav mesh must be at 000
	# that way, local and global pos is the same
	path = nav.get_simple_path(our_pos, goal_pos)
	
	var end_pos = goal_pos
	
	if path.size() > 1:
		end_pos = path[1]
	
	#vector pointing from our pos to goal pos
	var dir = end_pos - our_pos
	#make this a 2d vector
	dir.y = 0
	character_mover.set_move_vec(dir)
	face_dir(dir, delta)
	anim_player.play("walk_loop")
	
func set_walk_pos(v: Vector3):
	walk_pos = v

func set_initial_pos(v: Vector3):
	initial_pos = v
