extends Node2D

onready var tilemap = $TileMap
onready var tileset = load("res://environment/mapgen/single_tilemap2.tres")
onready var autotile = load("res://environment/mapgen/autotile.tres")
onready var a_star = preload("res://environment/scripts/a_star.gd").new()
onready var boruvka = preload("res://environment/scripts/boruvka.gd").new()

export var nf: int = 1

export var nr: int = 4

export var fx: int = 32
export var fy: int = 32
var fs: Vector2

export var rx: int = 3
export var ry: int = 3
var rs: Vector2

export var bx: int = 1
export var by: int = 1
var bs: Vector2

# vectors
var g_vectors: Array = []

# edges
var g_edges: Array = []

# AStar
var astar: AStar2D

var rooms: Array

class Room:
	var corner: Vector2
	var size: Vector2
	var door_n: Vector2
	var door_s: Vector2
	var door_e: Vector2
	var door_w: Vector2

	func _init(c: Vector2, s:Vector2):
		self.corner = c
		self.size = s
		calc_doors()

	func calc_doors():
		self.door_n = Vector2(corner.x + (size.x - int(size.x)%2)/2, corner.y)
		self.door_s = Vector2(corner.x - (size.x - int(size.x)%2)/2, corner.y)
		self.door_e = Vector2(corner.x, corner.y + (size.y - int(size.y)%2)/2)
		self.door_w = Vector2(corner.x, corner.y - (size.y - int(size.y)%2)/2)

		
func _ready():
	astar = AStar2D.new()
	bs = Vector2(bx, by)
	fs = Vector2(fx, fy)
	rs = Vector2(rx, ry)
	astar.reserve_space(fs.x*fs.y)
	
	#tilemap = TileMap.new()
	#tilemap.tile_set = autotile
	#seed(3)
	tilemap.tile_set = tileset
	randomize()
	generate()


func generate():
	var edges = false
	while !edges:
		tilemap.clear()
		# place rooms (vectors)
		rooms = calc_rooms()
		# calculate mst of complete graph
		edges = boruvka.calc_mst_boruvka(rooms)
	# do internal astar pathing
	var paths = internal_astar(edges)
	# place paths
	for path in paths:
		# pass
		# print(path)
		if len(path):
			place_path(path)
	# update the bitmask region if autotiling
	# tilemap.update_bitmask_region()
	return tilemap


func internal_astar(edges):
	#disable all room tiles
	for i in fs.x:
		for j in fs.y:
			var idx = getAStarCellId(Vector2(i,j))
			astar.add_point(idx, Vector2(i,j))
			if tilemap.get_cell(i,j) != -1:
			# 	pass
				astar.set_point_disabled(idx)
				# tilemap.set_cellv(astar.get_point_position(idx), tn("h"))


	# here, you need to connect all euclidian points
	for i in fs.x:
		for j in fs.y:
			var cur_cell =	Vector2(i,j)
			var up = cur_cell + Vector2.UP
			var down = cur_cell + Vector2.DOWN
			var left = cur_cell + Vector2.LEFT
			var right = cur_cell + Vector2.RIGHT
			if getAStarCellId(up):
				astar.connect_points(
					getAStarCellId(cur_cell),
					getAStarCellId(up)
				)
			if getAStarCellId(down):
				astar.connect_points(
					getAStarCellId(cur_cell),
					getAStarCellId(down)
				)
			if getAStarCellId(left):
				astar.connect_points(
					getAStarCellId(cur_cell),
					getAStarCellId(left)
				)
			if getAStarCellId(right):
				astar.connect_points(
					getAStarCellId(cur_cell),
					getAStarCellId(right)
				)

	# do a* calculations
	var paths = []
	for i in edges:
		var start = getAStarCellId(i.vs[0].v)
		var end = getAStarCellId(i.vs[1].v)

		#print(len(astar.get_points()))

		astar.set_point_disabled(start, false)
		astar.set_point_disabled(end, false)

		var path = astar.get_point_path(start, end)

		# print(path)
		paths.append(path)
	
	return paths


func getAStarCellId(vCell:Vector2):
	var id = int(vCell.y*fs.y + vCell.x)
	if id >= 0:
		return id
	else:
		return null


func calc_rooms():
	var rooms_list = []
		
	# generate rooms
	for i in range(nr):
		
		# create room size
		var x = randi() % int(rs.x-1) + 1
		var y = randi() % int(rs.y-1) + 1 

		var size = Vector2(x, y)
		
		var valid = false
		var corner = null
		while !valid:
			var j = randi() % int(fs.x)
			var k = randi() % int(fs.y)
			corner = Vector2(j,k)
			valid = check_valid_room(corner, size)
		
		#place_room_auto(corner, size)
		place_room(corner,size)
		rooms_list.append(Room.new(corner, size))
		
	return rooms_list


func place_path(path):
	#print(path)

	for i in range(len(path)):
		var cur = tilemap.get_cellv(path[i])

		var x_flip = tilemap.is_cell_x_flipped(path[i].x, path[i].y)
		var y_flip = tilemap.is_cell_y_flipped(path[i].x, path[i].y)
		var transposed = tilemap.is_cell_transposed(path[i].x, path[i].y)

		var new_tile = null

		if cur == tn("wall"):
			tilemap.set_cellv(
				path[i],
				tn("door"),
				x_flip,
				y_flip,
				transposed
			)
		
		elif cur == tn("corner"):
			#check the next cell for orientation
			new_tile = tn("corner_door_l")
			if (i+1 < len(path)):
				if path[i+1].y!= path[i].y:
					pass
				else:
					transposed = !transposed
					y_flip = !y_flip
					x_flip = !x_flip
			else:
				if path[i-1].y!= path[i].y:
					pass
				else:
					transposed = !transposed
					y_flip = !y_flip
					x_flip = !x_flip
		
		
		elif cur == tn("corner_door_l"):
			new_tile = tn("corner_door")
			# if (i+1 < len(path)):
			# 	if (path[i+1].y != path[i].y):
			# 		new_tile = tn("corner_door_l")
			# 	else:
			# 		new_tile = tn("corner_door")
			# else:
			# 	if (path[i-1].y != path[i].y):
			# 		new_tile = tn("corner_door_l")
			# 	else:
			# 		new_tile = tn("corner_door")

		elif cur == tn("door"):
			new_tile = tn("door")
		
		elif cur == tn("corner_door"):
			new_tile = tn("corner_door")
		
		else:
			# handle relation to successor vectors
			var prev_vec = null
			var next_vec = null
			# get prev tile vector
			if i > 0:
				prev_vec = path[i] - path[i-1]
			# get next tile vector
			if i < len(path):
				next_vec = path[i] - path[i+1]
			
			# prev: left	next: down	want: ne corner
			if comp_vec(prev_vec, next_vec, Vector2.LEFT, Vector2.DOWN):
				new_tile = tn("hall_corner")
				x_flip = false
				y_flip = false
				transposed = true
				if cur != -1:
					var res = handle_layer(path[i], new_tile, x_flip, y_flip, transposed)
					new_tile = res[0] 
					x_flip = res[1] 
					y_flip = res[2]
					transposed = res[3]
			# prev: right	next: down	want: nw corner
			elif comp_vec(prev_vec, next_vec, Vector2.RIGHT, Vector2.DOWN):
				new_tile = tn("hall_corner")
				x_flip = true
				y_flip = false
				transposed = true
				if cur != -1:
					var res = handle_layer(path[i], new_tile, x_flip, y_flip, transposed)
					new_tile = res[0] 
					x_flip = res[1] 
					y_flip = res[2]
					transposed = res[3]
			# prev: left	next: up	want: se corner
			elif comp_vec(prev_vec, next_vec, Vector2.LEFT, Vector2.UP):
				new_tile = tn("hall_corner")
				x_flip = false
				y_flip = true
				transposed = true
				if cur != -1:
					var res = handle_layer(path[i], new_tile, x_flip, y_flip, transposed)
					new_tile = res[0] 
					x_flip = res[1] 
					y_flip = res[2]
					transposed = res[3]
			# prev: right	next: up	want: sw corner
			elif comp_vec(prev_vec, next_vec, Vector2.RIGHT, Vector2.UP):
				new_tile = tn("hall_corner")
				x_flip = true
				y_flip = true
				transposed = true
				if cur != -1:
					var res = handle_layer(path[i], new_tile, x_flip, y_flip, transposed)
					new_tile = res[0] 
					x_flip = res[1] 
					y_flip = res[2]
					transposed = res[3]
			# prev: up		next: down	want: hall vert
			# prev: down	next: up	want: hall vert
			elif comp_vec(prev_vec, next_vec, Vector2.UP, Vector2.DOWN):
				new_tile = tn("hall")
				x_flip = false
				y_flip = false
				transposed = false
				if cur != -1:
					var res = handle_layer(path[i], new_tile, x_flip, y_flip, transposed)
					new_tile = res[0] 
					x_flip = res[1] 
					y_flip = res[2]
					transposed = res[3]
			# prev: left	next: right	want: hall horiz
			# prev: right	next: left	want: hall horiz
			elif comp_vec(prev_vec, next_vec, Vector2.LEFT, Vector2.RIGHT):
				new_tile = tn("hall")
				x_flip = false
				y_flip = false
				transposed = true
				if cur != -1:
					var res = handle_layer(path[i], new_tile, x_flip, y_flip, transposed)
					new_tile = res[0] 
					x_flip = res[1] 
					y_flip = res[2]
					transposed = res[3]

			else:
				print("UNMATCHED:")
				print(path[i])
				print(prev_vec, next_vec)
				new_tile = -1
				print("\n")
		
		if new_tile:
			tilemap.set_cellv(
				path[i],
				new_tile,
				x_flip,
				y_flip,
				transposed
			)
		if new_tile == tn("corner_door"):
			tilemap.set_cellv(
				path[i],
				0,
				x_flip,
				y_flip,
				transposed
			)


func comp_vec(v1a, v1b, v2a, v2b):
	if v1a == v2a and v1b == v2b:
		return true
	if v1a == v2b and v2a == v1b:
		return true
	return false


func handle_layer(cur_loc, attempted_tile, x_flip, y_flip, transposed):
	# function to handle the layering of cells
	var new_tile = null

	var cur_tile = tilemap.get_cellv(cur_loc)
	var cur_x_flip = tilemap.is_cell_x_flipped(cur_loc.x, cur_loc.y)
	var cur_y_flip = tilemap.is_cell_y_flipped(cur_loc.x, cur_loc.y)
	var cur_transposed = tilemap.is_cell_transposed(cur_loc.x, cur_loc.y)

	# if the current tile is a 4 way, it's always a 4 way
	if cur_tile == tn("hall_quad"):
		new_tile = tn("hall_quad")
		x_flip = false
		y_flip = false
		transposed = false

	# make hall_quad from composits
	elif (
		# h_v, h_h
		(comp_vec(cur_tile, attempted_tile, tn("hall"), tn("hall")) and
			cur_transposed != transposed) or
		# se, nw; sw, ne
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall_corner")) and
			cur_x_flip != x_flip and
			cur_y_flip != y_flip) or
		# tri_north/tri_south and h_v; tri_east/tri_west and h_h
		(comp_vec(cur_tile, attempted_tile, tn("hall_tri"), tn("hall")) and
			cur_transposed == transposed)
	):
		new_tile = tn("hall_quad")
		x_flip = false
		y_flip = false
		transposed = false
	
	# make hall_tri facing north
	elif (
		# se, sw
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall_corner")) and
			cur_x_flip != x_flip and
			cur_y_flip == y_flip and
			y_flip == true) or
		# se, h_h; sw, h_h
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall")) and
			cur_y_flip == y_flip and
			y_flip == true and
			cur_transposed == transposed)
	):
		new_tile = tn("hall_tri")
		x_flip = false
		y_flip = false
		transposed = false
	
	# make hall_tri facing south
	elif (
		# ne, nw
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall_corner")) and
			cur_x_flip != x_flip and
			cur_y_flip == y_flip and
			y_flip == false) or
		# ne, h_h; nw, h_h
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall")) and
			cur_y_flip != y_flip and
			cur_transposed == transposed)
	):
		new_tile = tn("hall_tri")
		x_flip = false
		y_flip = true
		transposed = false

	# make hall_tri facing east
	elif (
		# nw, sw
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall_corner")) and
			cur_x_flip == x_flip and
			x_flip == true and
			cur_y_flip != y_flip) or
		# nw, h_v; sw, h_v
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall")) and
			cur_x_flip != x_flip and
			cur_transposed != transposed)
	):
		new_tile = tn("hall_tri")
		x_flip = false
		y_flip = false
		transposed = true

	# make hall_tri facing west
	elif (
		# ne, se
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall_corner")) and
			cur_x_flip == x_flip and
			x_flip == false and
			cur_y_flip != y_flip) or
		# ne, h_v; se, h_v
		(comp_vec(cur_tile, attempted_tile, tn("hall_corner"), tn("hall")) and
			cur_x_flip == x_flip and
			cur_transposed != transposed)
	):
		new_tile = tn("hall_tri")
		x_flip = true
		y_flip = false
		transposed = true

	elif (cur_tile == attempted_tile and
		cur_x_flip == x_flip and
		cur_y_flip == y_flip and
		cur_transposed == transposed
	):
		new_tile = cur_tile


	return [new_tile, x_flip, y_flip, transposed]


func place_path_autotile(path):
	tilemap.set_cellv(path[1],0)
	tilemap.set_cellv(path[-2],0)
	
	for i in range(1, len(path)-1):
		# if path[i] != path[-1] and i != 0:
		tilemap.set_cellv(path[i],2)
		

func place_room(c: Vector2, s: Vector2):
	#creates a room with no checks
	# assume both vector sizes are >2
	# var tc = c
	# c.x = c.x - (s.x - int(s.x)%2)/2
	# c.y = c.y - (s.y - int(s.y)%2)/2
	
	# do north wall
	tilemap.set_cellv(c, tn("corner"), true)
	for i in range(c.x+1, c.x+s.x):
		tilemap.set_cell(i, c.y, tn("wall"))
	tilemap.set_cell(c.x+s.x, c.y, tn("corner"))
	
	# do middle walls
	for i in range(c.y+1, c.y+s.y):
		tilemap.set_cell(c.x, i, tn("wall"), false, false, true)
		for j in range(c.x+1, c.x+s.x):
			tilemap.set_cell(j, i, tn("floor"))
		tilemap.set_cell(c.x+s.x, i, tn("wall"), true, true, true)
	
	# do south wall
	tilemap.set_cell(c.x, c.y+s.y, tn("corner"), true, true)
	for i in range(c.x+1, c.x+s.x):
		tilemap.set_cell(i, c.y+s.y, tn("wall"), false, true)
	tilemap.set_cell(c.x+s.x, c.y + s.y, tn("corner"), false, true)

	# check true corner
	# tilemap.set_cellv(tc,-1)

func place_room_auto(c: Vector2, s: Vector2):
	c.x = c.x - (s.x - int(s.x)%2)/2
	c.y = c.y - (s.y - int(s.y)%2)/2
	for i in range(c.x, c.x+s.x):
		for j in range(c.y, c.y+s.y):
			tilemap.set_cell(i,j,0)
	

	

# =====================================
# HELPERS
# =====================================

func tn(name: String):
	return tilemap.get_tileset().find_tile_by_name(name)

func check_valid(c: Vector2, vectors: Array):
	# check that there are no tiles in surrounding space s
	for v in vectors:
		var vec = v.v
		if ((vec.x <= (c.x + bs.x) and
			vec.x >= (c.x - bs.x)) or
			(vec.y <= (c.y + bs.y) and
			vec.y >= (c.y - bs.y))):
			return false
	return true

func check_valid_room(c: Vector2, s: Vector2):
	# check that the whole room is inside the map
	var h_spaces = s.x
	var v_spaces = s.y

	if ((c.x + h_spaces) > fs.x or
		(c.y + v_spaces) > fs.y):
		return false

	# check that we do not intersect with another room plus buffer
	for j in range(c.y-bs.y, c.y+v_spaces+bs.y+1):
		for i in range(c.x-bs.x, c.x+h_spaces+bs.x+1):
			if tilemap.get_cell(i, j) != -1:
				return false
	return true

	

