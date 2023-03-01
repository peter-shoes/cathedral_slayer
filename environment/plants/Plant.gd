extends Spatial

onready var sprite = $Sprite3D
onready var plants = load("res://environment/plants/sprites/")
var dir_length = 17; #change this to the number of files in the directory

func _ready():
	# generate random number between 0 and length
	var random = randi() % dir_length
	random = str(random)
	var texture = load("res://environment/plants/sprites/plant" + random + ".png")
	# var texture = load("res://environment/plants/sprites/plant20.png")
	# var tex_obj = Texture.new()
	
	sprite.set_texture(texture)
	var width = sprite.texture.get_width()/100
	sprite.offset.x += width
