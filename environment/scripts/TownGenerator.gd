extends Spatial

onready var dungeon_grid = $DungeonGrid
onready var generator = $Gridmap
onready var navigation = $Navigation
onready var navmesh = $Navigation/NavigationMeshInstance
onready var lantern = load("res://environment/Lantern.tscn")
onready var metlar = load("res://characters/enemies/Metlar.tscn")
onready var plant = load("res://environment/plants/Plant.tscn")
onready var dracula = load("res://characters/enemies/enemy_scenes/Dracula.tscn")
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
			if cur_tile == -1:
				start_loc = loc
				place_tile(generator.tn("floor"), loc)
	# This is a bad way to do this, but here we stack rooms
	for i in generator.rooms:
		var floors = (randi() % 2) + 2
		for x in range(i.corner.x + i.size.x):
			for y in range(i.corner.y + i.size.y):
				var cur = tilemap.get_cellv(Vector2(x,y))
				for j in range(1, floors-1):
					if cur == generator.tn("wall"):
						dungeon_grid.set_cell_item(x, j, y, tn("wall1"), 
						dungeon_grid.get_cell_item_orientation(x,0,y))
					elif cur == generator.tn("corner"):
						dungeon_grid.set_cell_item(x, j, y, tn("corner0"),
						dungeon_grid.get_cell_item_orientation(x,0,y))
					else:
						print(cur)
				# if cur == generator.tn("wall"):
				# 	dungeon_grid.set_cell_item(x, floors, y, tn("wall2"),
				# 	dungeon_grid.get_cell_item_orientation(x,0,y))
				# elif cur == generator.tn("corner"):
				# 	dungeon_grid.set_cell_item(x, floors, y, tn("corner2"),
				# 	dungeon_grid.get_cell_item_orientation(x,0,y))
				# elif cur == generator.tn("floor"):
				# 	dungeon_grid.set_cell_item(x, floors, y, tn("ceil"),
				# 	dungeon_grid.get_cell_item_orientation(x,0,y))
				# else:
				# 	print("missing")

	# var used_rect = generator.tilemap.get_used_rect()

	# floor_mesh.scale.x = used_rect.size.x * dungeon_grid.cell_size.x * dungeon_grid.scale.x
	# floor_mesh.scale.y = used_rect.size.y * dungeon_grid.cell_size.y * dungeon_grid.scale.y
	# var loc_map = dungeon_grid.map_to_world(used_rect.position.x, used_rect.position.y, 1)
	# floor_mesh.translation.x += loc_map.x
	# floor_mesh.translation.z += loc_map.y
	# floor_mesh.translation.y += 1.01
	# go navmesh
	#var nav = EditorNavigationMeshGenerator.new().NavigationMeshGenerator
	var _navmesh: NavigationMesh = NavigationMesh.new()
	_navmesh.set_agent_radius(16)
	NavigationMeshGenerator.bake(_navmesh, self)
	navmesh.navmesh = null
	navmesh.navmesh = _navmesh
	
	# place items in rooms
	# var valid_locs = []
	# for i in range(generator.fs.x):
	# 	for j in range(generator.fs.y):
	# 		var loc = Vector3(i, z_level, j)
	# 		var loc2 = Vector2(i,j)
	# 		var cur_tile = tilemap.get_cellv(loc2)
	# 		if cur_tile != -1:
	# 			if randi()%8 == 1:
	# 				if !len(valid_locs):
	# 					valid_locs.append(loc)
	# 				else:
	# 					var drac = dracula.instance()
	# 					navigation.add_child(drac)
	# 					place_in_world(drac, i, z_level, j, false)
	# 					var walk_loc = valid_locs[randi()%len(valid_locs)]
	# 					var world_loc = dungeon_grid.map_to_world(walk_loc.x, walk_loc.y, walk_loc.z) * dungeon_grid.scale.x
	# 					drac.set_walk_pos(world_loc)
	# 			else:
	# 				valid_locs.append(loc)
		
	
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
		tile = tn("floor")
	
	# # walls
	elif type == generator.tn("wall"):
		var o = get_cell_rotation(xf, yf, tp, tn("wall0"))
		tile = tn("wall0")

	#corners
	elif type == generator.tn("corner"):
		tile = tn("corner0")
		# orientation = 16
	
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
	var orientation = 0
	var replacement_mesh = null
	
	if (
		tile == tn("corner0") or 
		tile == tn("corner1") or 
		tile == tn("corner2")
	):
		if (!xf and !yf):
			orientation = 22
		if (!xf and yf):
			orientation = 10
		if (xf and yf):
			orientation = 16
		if (xf and !yf):
			orientation = 0
	
	elif (
		tile == tn("wall0") or
		tile == tn("wall1") or
		tile == tn("wall2")
	):
		if (!xf and !yf and !tp):
			orientation = 22
		if (!xf and !yf and tp):
			orientation = 0
		if (xf and yf and tp):
			orientation = 10
		if (!xf and yf and !tp):
			orientation = 16

	return orientation
	
func tn(n: String):
	return dungeon_grid.mesh_library.find_item_by_name(n)

func place_in_world(object, x, y, z, random_offset = false):
	if random_offset:
		var offset = Vector3(
			rand_range(-0.5, 0.5),
			0,
			rand_range(-0.5, 0.5)) * dungeon_grid.scale.x * dungeon_grid.cell_size.x
		object.translation = dungeon_grid.map_to_world(
			x,
			y, 
			z) * dungeon_grid.scale.x + offset
	else:
		object.translation = dungeon_grid.map_to_world(
			x,
			y, 
			z) * dungeon_grid.scale.x
