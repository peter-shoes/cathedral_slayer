extends Control

onready var vp = $ViewportContainer/Viewport
onready var vpc = $ViewportContainer
onready var sprite = $ViewportContainer/Viewport/Sprite
onready var cam: Camera
export (NodePath) var target

export var scale: int

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	vpc._set_size(Vector2(scale,scale))
	vp.set_size(Vector2(scale,scale))
	sprite.position = Vector2(scale/2, scale/2)
	cam = Camera.new()
	cam.set_projection(1)
	cam.size = 100
	vp.add_child(cam)
	#vp.add_child()
	pass # Replace with function body.

func _process(delta):
	cam.translation = Vector3(target.translation.x, 20, target.translation.z)
	cam.rotation_degrees = Vector3(-90, target.rotation_degrees.y, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
