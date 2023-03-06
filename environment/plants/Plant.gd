extends Spatial

onready var sprite = $Sprite3D
#onready var texture_rect = $Viewport/TextureRect
#onready var viewport = $Viewport
onready var plants = load("res://environment/plants/sprites/")
var dir_length = 17; #change this to the number of files in the directory

func _ready():
	randomize()
	# generate random number between 0 and length
	var random = randi() % dir_length
	random = str(random)
	var texture = load("res://environment/plants/sprites/plant" + random + ".png")
	
	basic_plants(texture)
	
	
	
#func material_plants(texture):
#	texture_rect.set_texture(texture)
	#viewport.size = Vector2(texture_rect.texture.get_width(),texture_rect.texture.get_height())
#	var width = texture_rect.texture.get_width()/100
#	sprite.offset.x += width
#	var r = randi()%100
#	texture_rect.material.set_shader_param("Offset", r)
	
func basic_plants(texture):
	sprite.set_texture(texture)
	#viewport.size = Vector2(texture_rect.texture.get_width(),texture_rect.texture.get_height())
	var width = sprite.texture.get_width()/100
	sprite.offset.x += width
	var r = randi()%100
	
