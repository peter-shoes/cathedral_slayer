extends Node2D

onready var tilemap = $TileMap
onready var tileset = load("res://environment/mapgen/single_tilemap.tres")
onready var autotile = load("res://environment/mapgen/autotile.tres")
onready var a_star = preload("res://environment/scripts/a_star.gd").new()
onready var boruvka = preload("res://environment/scripts/boruvka.gd").new()

export var nf: int

export var nr: int = 2

export var fx: int = 32
export var fy: int = 32
var fs: Vector2

export var rx: int = 8
export var ry: int = 8
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
	var center: Vector2
	var size: Vector2
	var door_n: Vector2
	var door_s: Vector2
	var door_e: Vector2
	var door_w: Vector2

	func _init(c: Vector2, s:Vector2):
		self.center = c
		self.size = s
		calc_doors()

	func calc_doors():
		self.door_n = Vector2(center.x + (size.x - int(size.x)%2)/2, center.y)
		self.door_s = Vector2(center.x - (size.x - int(size.x)%2)/2, center.y)
		self.door_e = Vector2(center.x, center.y + (size.y - int(size.y)%2)/2)
		self.door_w = Vector2(center.x, center.y - (size.y - int(size.y)%2)/2)

		
func _ready():
	astar = AStar2D.new()
	bs = Vector2(bx, by)
	fs = Vector2(fx, fy)
	rs = Vector2(rx, ry)
	astar.reserve_space(fs.x*fs.y)
	tilemap.clear()
	#tilemap = TileMap.new()
	#tilemap.tile_set = autotile
	tilemap.tile_set = tileset
	#seed(3)
	randomize()
	generate()


func generate():
	# place rooms (vectors)
	rooms = calc_rooms()
	# calculate mst of complete graph
	var edges = boruvka.calc_mst_boruvka(rooms)
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
	var rooms = []

	if (rs.x <= 2) or (rs.y <= 2):
		push_error("size too small")
		
	# generate rooms
	for i in range(nr):
		
		# create room size
		var x = randi() % int(rs.x-3) + 3
		var y = randi() % int(rs.y-3) + 3
		x = (x - x%2) 
		y = (y - y%2) 

		var size = Vector2(x, y)
		
		var valid = false
		var center = null
		while !valid:
			var j = randi() % int(fs.x)
			var k = randi() % int(fs.y)
			center = Vector2(j,k)
			valid = check_valid_room(center, size)
		
		#place_room_auto(center, size)
		place_room(center,size)
		rooms.append(Room.new(center, size))
		
	return rooms


func place_path(path):
	
	var prev_vec = null
	var set_vec = null
	
	var a = path[0]
	var b = path[-1]

	for j in [a,b]:
		var cur = tilemap.get_cellv(j)
		if cur == tn("w_n"):
			tilemap.set_cellv(j, tn("wd_n"))
			prev_vec = Vector2.UP
		elif cur == tn("w_s"):
			tilemap.set_cellv(j, tn("wd_s"))
			prev_vec = Vector2.DOWN
		elif cur == tn("w_e"):
			tilemap.set_cellv(j, tn("wd_e"))
			prev_vec = Vector2.RIGHT
		elif cur == tn("w_w"):
			tilemap.set_cellv(j, tn("wd_w"))
			prev_vec = Vector2.LEFT
	
	var i = 0
	while i < len(path):		
		if set_vec:
			prev_vec = set_vec

		set_vec = path[i] - path[i-1]

		if ((prev_vec == Vector2.UP and set_vec == Vector2.UP) or
			(prev_vec == Vector2.DOWN and set_vec == Vector2.DOWN)):
			tilemap.set_cellv(path[i-1], tn("h_v"))
		elif ((prev_vec == Vector2.LEFT and set_vec == Vector2.LEFT) or
			(prev_vec == Vector2.RIGHT and set_vec == Vector2.RIGHT)):
			tilemap.set_cellv(path[i-1], tn("h_h"))
		elif ((prev_vec == Vector2.LEFT and set_vec == Vector2.UP) or
			(prev_vec == Vector2.DOWN and set_vec == Vector2.RIGHT)):
			tilemap.set_cellv(path[i-1], tn("hc_sw"))
		elif ((prev_vec == Vector2.RIGHT and set_vec == Vector2.UP) or
			(prev_vec == Vector2.DOWN and set_vec == Vector2.LEFT)):
			tilemap.set_cellv(path[i-1], tn("hc_se"))
		elif ((prev_vec == Vector2.LEFT and set_vec == Vector2.DOWN) or
			(prev_vec == Vector2.UP and set_vec == Vector2.RIGHT)):
			tilemap.set_cellv(path[i-1], tn("hc_nw"))
		elif ((prev_vec == Vector2.RIGHT and set_vec == Vector2.DOWN) or
			(prev_vec == Vector2.UP and set_vec == Vector2.LEFT)):
			tilemap.set_cellv(path[i-1], tn("hc_ne"))
		
		i += 1


func place_path_autotile(path):
	tilemap.set_cellv(path[1],0)
	tilemap.set_cellv(path[-2],0)
	
	for i in range(1, len(path)-1):
		# if path[i] != path[-1] and i != 0:
		tilemap.set_cellv(path[i],2)
		

func place_room(c: Vector2, s: Vector2):
	#creates a room with no checks
	# assume both vector sizes are >2
	var tc = c
	c.x = c.x - (s.x - int(s.x)%2)/2
	c.y = c.y - (s.y - int(s.y)%2)/2
	
	# do north wall
	tilemap.set_cellv(c, tn("wc_nw"))
	for i in range(c.x+1, c.x+s.x):
		tilemap.set_cell(i, c.y, tn("w_n"))
	tilemap.set_cell(c.x+s.x, c.y, tn("wc_ne"))
	
	# do middle walls
	for i in range(c.y+1, c.y+s.y):
		tilemap.set_cell(c.x, i, tn("w_w"))
		for j in range(c.x+1, c.x+s.x):
			tilemap.set_cell(j, i, tn("f"))
		tilemap.set_cell(c.x+s.x, i, tn("w_e"))
	
	# do south wall
	tilemap.set_cell(c.x, c.y+s.y, tn("wc_sw"))
	for i in range(c.x+1, c.x+s.x):
		tilemap.set_cell(i, c.y+s.y, tn("w_s"))
	tilemap.set_cell(c.x+s.x, c.y + s.y, tn("wc_se"))

	# check true center
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
	var h_spaces = int((s.x - int(s.x)%2) / 2) + 1
	var v_spaces = int((s.y - int(s.y)%2) / 2) + 1
	var h_size = Vector2(h_spaces, v_spaces)

	if ((c.x + h_spaces) > fs.x or
		(c.x - h_spaces) < 0	or
		(c.y + v_spaces) > fs.y or
		(c.y - v_spaces) < 0):
		return false

	# check that we do not intersect with another room plus buffer
	var low_x = c.x - h_size.x - bs.x - 1
	var high_x = c.x + h_size.x + bs.x + 1
	var low_y = c.y - h_size.y - bs.y - 1
	var high_y = c.y + h_size.y + bs.y + 1
	for j in range(low_y, high_y):
		for i in range(low_x, high_x):
			if tilemap.get_cell(i, j) != -1:
				return false
	return true

	

