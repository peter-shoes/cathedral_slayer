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
			# if cur_tile != -1:
			# 	add_child(lantern.instance())
			# 	var li = get_children()[-1]
			# 	var trans = dungeon_grid.map_to_world(loc2.x, dungeon_grid.cell_size.x*dungeon_grid.cell_scale, loc2.y)
			# 	# trans.y *= 1.5
			# 	li.translation = trans * dungeon_grid.scale.x

	# var used_rect = generator.tilemap.get_used_rect()

	# floor_mesh.scale.x = used_rect.size.x * dungeon_grid.cell_size.x * dungeon_grid.scale.x
	# floor_mesh.scale.y = used_rect.size.y * dungeon_grid.cell_size.y * dungeon_grid.scale.y
	# var loc_map = dungeon_grid.map_to_world(used_rect.position.x, used_rect.position.y, 1)
	# floor_mesh.translation.x += loc_map.x
	# floor_mesh.translation.z += loc_map.y
	# floor_mesh.translation.y += 1.01
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
	# convert tilemap orientation to gridmap orientation
	# orientations are 0, 16, 22, 10
	var xf = tilemap.is_cell_x_flipped(loc.x, loc.z)
	var yf = tilemap.is_cell_y_flipped(loc.x, loc.z)
	var tp = tilemap.is_cell_transposed(loc.x, loc.z)
	var orientation = null
	
	#floor
	if type == generator.tn("floor"):
		tile = tn("floor_cistern_double2")
	
	# # walls
	elif type == generator.tn("wall"):
		var o = get_cell_rotation(xf, yf, tp, tn("wall2"))
		if o == 6 or o == 12:
			tile = tn("wall_cistern2")
			# tile = -1
		else:
			tile = tn("wall2")
			# tile = -1

	#doors
	elif type == generator.tn("door"):
		var o = get_cell_rotation(xf, yf, tp, tn("wall2"))
		if o == 6 or o == 12:
			tile = tn("wall_cistern_door2")
		else:
			tile = tn("wall_door2")

	#corners
	elif type == generator.tn("corner"):
		tile = tn("corner2")

	# corner door l
	elif type == generator.tn("corner_door_l"):
		if ((tp and xf and yf) or
			(!tp and xf and !yf) or
			(tp and !xf and !yf)
			):
			tile = tn("corner_door_r2")
		else:
			tile = tn("corner_door_l2")
			# tile = -1
		# orientation = 16

	# corner door
	elif type == generator.tn("corner_door"):
		tile = tn("corner_door2")
		tp = false
		# orientation = 16

	#halls
	elif type == generator.tn("hall"):
		tile = tn("hall_double2")
		# orientation = 0

	#hall corners
	elif type == generator.tn("hall_corner"):
		tile = tn("hall_corner2")

	# #hall tris
	# elif type == generator.tn("hall_tri"):
	# 	tile = tn("hall_tri2")
	
	#hall quads
	elif type == generator.tn("hall_quad"):
		tile = tn("hall2")
	
	else:
		tile = -1

	# if tile == tn("floor"):
	if tile != -1:
		if not orientation:
			orientation = get_cell_rotation(xf, yf, tp, tile)
		dungeon_grid.set_cell_item(loc.x, loc.y, loc.z, tile, orientation)
		# if tile == tn("wall"):
		# 	dungeon_grid.set_cell_item(loc.x, loc.y, loc.z, tn("floor"))
		# 	dungeon_grid_walls.set_cell_item(loc.x, loc.y, loc.z, tn("wall"), orientation)
		if !found_start:
			start_loc = loc
			found_start = true
			
func get_cell_rotation(xf, yf, tp, tile):
	# ini 0: n, 1: s, 2: e, 3: w
	# 6, 12, 17, 21
	var orientation = 6
	var replacement_mesh = null
	
	if (
		tile == tn("corner2") or
		tile == tn("corner_door2") 
	):
		if (!xf and !yf):
			orientation = 21
		if (!xf and yf):
			orientation = 6
		if (xf and yf):
			orientation = 17
		if (xf and !yf):
			orientation = 12
	
	if (
		tile == tn("corner_door_l2") or
		tile == tn("corner_door_r2")
	):
		if (!tp):
			if (!xf and !yf):
				orientation = 21
			if (!xf and yf):
				orientation = 6
			if (xf and yf):
				orientation = 17
			if (xf and !yf):
				orientation = 12
		else:
			if (!xf and !yf):
				orientation = 17
			if (!xf and yf):
				orientation = 12
			if (xf and yf):
				orientation = 21
			if (xf and !yf):
				orientation = 6

	elif (
		tile == tn("hall_corner2")
	):
		if (!xf and !yf):
			orientation = 21
		if (xf and !yf):
			orientation = 12
		if (!xf and yf):
			orientation = 6
		if (xf and yf):
			orientation = 17
	
	elif (
		tile == tn("wall2") or
		tile == tn("wall_door2") or
		tile == tn("wall_cistern2") or
		tile == tn("wall_cistern_door2")
	):
		if (!xf and !yf and !tp):
			orientation = 12
		if (!xf and !yf and tp):
			orientation = 17
		if (xf and yf and tp):
			orientation = 21
		if (!xf and yf and !tp):
			orientation = 6

	elif (
		tile == tn("hall_double2")
	):
		if tp:
			orientation = 6
		else:
			orientation = 17
	
	
	return orientation
	
func tn(n: String):
	return dungeon_grid.mesh_library.find_item_by_name(n)
