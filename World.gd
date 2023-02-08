extends Spatial

onready var dungeon = $DungeonGenerator
onready var dungeon_grid = $DungeonGenerator/DungeonGrid
onready var player = $Player
onready var minimap = load("res://environment/Minimap.tscn")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var trans = dungeon_grid.map_to_world(dungeon.start_loc.x, dungeon.start_loc.y, dungeon.start_loc.z)
	player.translation = trans*dungeon_grid.scale.x
	print(player.translation)
	set_minimap()

func set_minimap():
	var mm = minimap.instance()
	mm.target = player
	# minimap.set_world_2d(dungeon.tilemap)
	player.camera.add_child(mm)

