extends Spatial

onready var dungeon_grid = $DungeonGrid
onready var dungeon_grid_walls = $DungeonGrid2
onready var dungeon_grid_ceil = $DungeonGrid3
onready var generator = $Gridmap
onready var navigation = $Navigation
onready var navmesh = $Navigation/NavigationMeshInstance
onready var lantern = load("res://environment/Lantern.tscn")
onready var metlar = load("res://characters/enemies/Metlar.tscn")
onready var floor_mesh = $FloorMesh

onready var found_start = false
onready var start_loc = null

var tilemap: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	generate()


func generate():
	var z_level = 0
	tilemap = generator.tilemap
	for i in range(generator.fs.x):
		for j in range(generator.fs.y):
			var loc = Vector3(i, z_level, j)
			var loc2 = Vector2(i,j)
			var cur_tile = tilemap.get_cellv(loc2)
			place_tile(cur_tile, loc)
			if cur_tile == generator.tn("f"):
				add_child(lantern.instance())
				var li = get_children()[-1]
				var trans = dungeon_grid.map_to_world(loc2.x, dungeon_grid.scale.x, loc2.y)
				# trans.y -= 2
				li.translation = trans * dungeon_grid.scale.x

	var used_rect = generator.tilemap.get_used_rect()

	floor_mesh.scale.x = used_rect.size.x * dungeon_grid.cell_size.x * dungeon_grid.scale.x
	floor_mesh.scale.y = used_rect.size.y * dungeon_grid.cell_size.y * dungeon_grid.scale.y
	var loc_map = dungeon_grid.map_to_world(used_rect.position.x, used_rect.position.y, 1)
	floor_mesh.translation.x += loc_map.x
	floor_mesh.translation.z += loc_map.y
	floor_mesh.translation.y += 1.01
	# go navmesh
	#var nav = EditorNavigationMeshGenerator.new().NavigationMeshGenerator
	NavigationMeshGenerator.bake(navmesh, dungeon_grid)
	# place items in rooms
	for i in generator.rooms:
		pass
		# if i == generator.rooms[0]:
		# 	navigation.add_child(metlar.instance())
		# 	var met = navigation.get_children()[-1]
		# 	trans = dungeon_grid.map_to_world(loc.x, dungeon_grid.cell_size.y * dungeon_grid.scale.y, loc.y)
		# 	trans.y -= 3
		# 	met.translation = trans*dungeon_grid.scale.x
		
	
func place_tile(type: int, loc: Vector3):
	var tile = null
	var orientation = 0
	#floor
	if type == generator.tn("f"):
		tile = tn("floor")
	# walls
	elif type == generator.tn("w_n"):
		tile = tn("wall")
		orientation = 4
	elif type == generator.tn("w_s"):
		tile = tn("wall")
		orientation = 14
	elif type == generator.tn("w_e"):
		tile = tn("wall")
		orientation = 23
	elif type == generator.tn("w_w"):
		tile = tn("wall")
		orientation = 19

	#corners
	elif type == generator.tn("wc_ne"):
		# tile = tn("wall")
		orientation = 0
	elif type == generator.tn("wc_nw"):
		# tile = tn("wall")
		orientation = 16
	elif type == generator.tn("wc_se"):
		# tile = tn("wall")
		orientation = 22
	elif type == generator.tn("wc_sw"):
		# tile = tn("wall")
		orientation = 10

	#doors
	elif type == generator.tn("wd_n"):
		tile = tn("door")
		orientation = 0
	elif type == generator.tn("wd_s"):
		tile = tn("door")
		orientation = 10
	elif type == generator.tn("wd_e"):
		tile = tn("door")
		orientation = 22
	elif type == generator.tn("wd_w"):
		tile = tn("door")
		orientation = 16

	#halls
	elif type == generator.tn("h_h"):
		tile = tn("hall")
		orientation = 16
	elif type == generator.tn("h_v"):
		tile = tn("hall")
		orientation = 0

	#hall corners
	elif type == generator.tn("hc_ne"):
		tile = tn("hall_corner")
		orientation = 16
	elif type == generator.tn("hc_nw"):
		tile = tn("hall_corner")
		orientation = 10
	elif type == generator.tn("hc_se"):
		tile = tn("hall_corner")
		orientation = 0
	elif type == generator.tn("hc_sw"):
		tile = tn("hall_corner")
		orientation = 22
	
	if tile == tn("floor"):
		dungeon_grid.set_cell_item(loc.x, loc.y, loc.z, tn("floor"))
	if tile == tn("wall"):
		dungeon_grid.set_cell_item(loc.x, loc.y, loc.z, tn("floor"))
		dungeon_grid_walls.set_cell_item(loc.x, loc.y, loc.z, tn("wall"), orientation)
	if !found_start and tile == tn("floor"):
		start_loc = loc
		found_start = true
			
		
	
func tn(n: String):
	return dungeon_grid.mesh_library.find_item_by_name(n)
