extends Spatial

#onready var dungeon = $DungeonGenerator
onready var dungeon = $ViewportContainer/Viewport/DungeonGenerator
#onready var dungeon_grid = $DungeonGenerator/DungeonGrid
onready var dungeon_grid = $ViewportContainer/Viewport/DungeonGenerator/Navigation/NavigationMeshInstance/DungeonGrid
#onready var player = $Player
onready var player = $ViewportContainer/Viewport/Player
onready var minimap = load("res://environment/Minimap.tscn")

onready var music = $MusicPlayer
onready var song = load("res://music/dungeon_5.ogg")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var trans = dungeon_grid.map_to_world(dungeon.start_loc.x, dungeon.start_loc.y, dungeon.start_loc.z)
	player.translation = trans*dungeon_grid.scale.x
	#set_minimap()
	#play_song()

func set_minimap():
	var mm = minimap.instance()
	mm.target = player
	# player.camera.add_child(dungeon.tilemap)
	player.camera.add_child(mm)
	mm.hide()
	
func play_song():
	music.stream = song
	music.play()


