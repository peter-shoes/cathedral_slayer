extends Control
onready var crosshair = $CrossHair
onready var mana_bar = $ManaBar
onready var health_bar = $HealthBar
onready var stamina_bar = $StaminaBar
onready var ability_menu = $AbilityMenu
onready var hurt_effect = $HurtEffect

var max_mana
var max_health
var max_stamina
var hurt_timer: Timer
var fade_timer: Timer

export var hurt_start_color: Color
var hurt_inter_color: Color


# Called when the node enters the scene tree for the first time.
func _ready():
	hurt_timer = Timer.new()
	hurt_timer.wait_time = 0.5
	hurt_timer.connect("timeout", self, "hide_pain")
	hurt_timer.one_shot = true
	add_child(hurt_timer)
	
	fade_timer = Timer.new()
	fade_timer.wait_time = 0.05
	fade_timer.connect("timeout", self, "fade_pain")
	fade_timer.one_shot = true
	add_child(fade_timer)
	
	mana_bar.set_value(100)
	health_bar.set_value(100)
	stamina_bar.set_value(100)
	hide_ability_menu()
	hurt_effect.hide()
	
	#update_mana_bar(mana_manager.get_max_mana())

func update_mana_pts(p: int):
	var mana_percent = float(p)/float(max_mana)
	
	mana_bar.set_value(mana_percent*100)

func update_mana_raw(v: int):
	mana_bar.set_value(v)

func set_max_mana(v: int):
	max_mana = v
	
func update_stamina_pts(p: int):
	var stamina_percent = float(p)/float(max_stamina)
	stamina_bar.set_value(stamina_percent*100)

func update_stamina_raw(v: int):
	stamina_bar.set_value(v)

func set_max_stamina(v: int):
	max_stamina = v
	
func update_health_pts(p: int):
	var old_health_percent = health_bar.get_value()/100
	var health_percent = float(p)/float(max_health)
	if old_health_percent > health_percent:
		play_hurt_effect()
	health_bar.set_value(health_percent*100)

func update_health_raw(v: int):
	health_bar.set_value(v)

func set_max_health(v: int):
	max_health = v

func show_ability_menu():
	ability_menu.show()
	
func hide_ability_menu():
	ability_menu.hide()
	
func play_hurt_effect():
	hurt_inter_color = hurt_start_color
	hurt_effect.set_modulate(hurt_start_color)
	hurt_effect.show()
	hurt_timer.start()
	fade_timer.start()
	
func hide_pain():
	hurt_effect.hide()
	
func fade_pain():
	if !hurt_timer.is_stopped():
		hurt_inter_color.a-=0.1
		hurt_effect.set_modulate(hurt_inter_color)
		fade_timer.start()
