extends Spatial

onready var anim_player = $AnimationPlayer
onready var bullet_emitters_base : Spatial = $BulletEmitters
onready var bullet_emitters = $BulletEmitters.get_children()
onready var spell_spawner = $BulletEmitters/SpellSpawner
onready var gui = get_parent().get_parent().get_parent().get_node("GUI")
onready var mana_manager = get_parent().get_parent().get_parent().get_parent().get_node("ManaManager")

export var automatic = false #whether or not the weapon is automatic

var fire_point : Spatial
var bodies_to_exclude : Array = []

export var damage = 5 #THIS MAKES EVERY BULLET DO THE SAME AMOUNT OF DAMAGE ; move this export var to the damage var in HitScanBulletEmitter to change

export var attack_rate = 0.2 #i believe this is in seconds
var attack_timer : Timer 
var can_attack = true #are we able to attack right now
var sound_to_play = 0

signal fired #these are just to connect them to sound effects
signal out_of_mana

func _ready():
	attack_timer = Timer.new() #create new timer obj
	attack_timer.wait_time = attack_rate #set the wait time on that obj to attack_rate var
	attack_timer.connect("timeout", self, "finish_attack") #on timeout, run the function finish_attack
	attack_timer.one_shot = true #timer will stop when it reaches 0
	add_child(attack_timer)
	
func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for bullet_emitter in bullet_emitters:
		bullet_emitter.set_damage(damage)
		bullet_emitter.set_bodies_to_exclude(bodies_to_exclude)
		
func attack(attack_input_just_pressed: bool, attack_input_held: bool):
	if !can_attack:
		return
	if automatic and !attack_input_held:
		return #if it's an automatic weapon and we're not holding attack, do nothing
	if !automatic and !attack_input_just_pressed:
		return
	if !mana_manager.spend_mana(spell_spawner.get_current_mana_cost()):
		return
		
	var start_transform = bullet_emitters_base.global_transform
	bullet_emitters_base.global_transform = fire_point.global_transform
	for bullet_emitter in bullet_emitters:
		bullet_emitter.fire()
	bullet_emitters_base.global_transform = start_transform
	#anim_player.stop() #animations must be stopped before another is played or else they'll just continue
	#anim_player.play("attack")
	emit_signal("fired")
	play_sound()
	can_attack = false #we just attacked so we can't attack anymore
	attack_timer.start() #until this timer is done
	
func finish_attack():
	can_attack = true

func set_active():
	show()
	#$Crosshair.show()
	
func set_inactive():
	#anim_player.play("idle")
	hide()
	#$Crosshair.hide()
	
func play_sound():
	return
	if sound_to_play == 0:
		sound_to_play += 1
	elif sound_to_play == 1:
		sound_to_play += 1
	else:
		sound_to_play = 0
