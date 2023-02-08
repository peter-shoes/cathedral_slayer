class Vector:
	var v: Vector2
	var cid: int
	var orig_cid: int

	func _init(vec: Vector2, c: int):
		self.v = vec
		self.cid = c
		self.orig_cid = self.cid


class Edge:
	var vs: Array = []
	var weight: float
	var distance

	func _init(i:Vector, j:Vector):
		vs.append(i)
		vs.append(j)
		vs.sort()
		self.calc_weight()
		

	func calc_weight():
		var lx = abs(vs[0].v.x-vs[1].v.x)
		var ly = abs(vs[0].v.y-vs[1].v.y)
		self.weight = pow(lx,2) + pow(ly,2)
		self.distance = sqrt(self.weight)

	func is_equal(e: Edge):
		if (((self.vs[0].v == e.vs[0].v) and 
			(self.vs[1].v == e.vs[1].v)) or 
			((self.vs[0].v == e.vs[1].v) and 
			(self.vs[0].v == e.vs[1].v))):
			return true
		return false



func calc_mst_boruvka(rooms: Array):
	var vectors = []
	var components = {}
	var closed_edges = []
	var open_edges = []
	var delaunay = null
	var count = 0

	# get delaunay edges before beginning
	# NOTE: the center array is now a corner array
	# With the new lack of minimums, we have no real center
	# So we will have to abandon delaunay and just get all possible edges
	# from all possible walls and corners
	for i in range(len(rooms)):
		for j in range(rooms[i].size.x):
			var cell1 = Vector2(
				rooms[i].corner.x+j,
				rooms[i].corner.y
			)
			var cell2 = Vector2(
				rooms[i].corner.x+j,
				rooms[i].corner.y + rooms[i].size.y
			)
			vectors.append(
				Vector.new(
					cell1,
					i
				)
			)
			vectors.append(
				Vector.new(
					cell2,
					i
				)
			)
		for j in range(rooms[i].size.y):
			var cell1 = Vector2(
				rooms[i].corner.x,
				rooms[i].corner.y+j
			)
			var cell2 = Vector2(
				rooms[i].corner.x + rooms[i].size.x,
				rooms[i].corner.y +j
			)
			vectors.append(
				Vector.new(
					cell1,
					i
				)
			)
			vectors.append(
				Vector.new(
					cell2,
					i
				)
			)

		# add component
		components[i] = null

	# make the edges
	for i in vectors:
		for j in vectors:
			if i.cid != j.cid:
				open_edges.append(Edge.new(i,j))
	
	# var new_edges = []
	# for i in open_edges:
	# 	for j in open_edges:
	# 		if !i.is_equal(j):
	# 			print("okay")

	var completed = false
	while !completed:
	
		#get lowest edges for each component
		for i in components:
			for j in open_edges:
				if j.vs[0].cid == i or j.vs[1].cid == i:
					if !components[i] or components[i].weight > j.weight:
						components[i] = j
		print(len(components))
		
		# consolidate connected components
		for i in components:
			# get the cid of the first component
			var master_cid = components[i].vs[0].cid
			# get the location of the second component
			var slave_loc = components[i].vs[1].v
			# search through the open edges to find the component with that location
			var slave_cid = null
			for j in open_edges:
				if j.vs[0].v == slave_loc:
					# get that cid
					slave_cid = j.vs[0].cid
					break
				elif j.vs[1].v == slave_loc:
					# get that cid
					slave_cid = j.vs[1].cid
					break
			# iterate through components again
			for j in open_edges:
				if j.vs[0].cid == slave_cid:
					# switch the cid of all components whose cid matches the second cid to the first cid
					j.vs[0].cid = master_cid
				if j.vs[1].cid == slave_cid:
					# switch the cid of all components whose cid matches the second cid to the first cid
					j.vs[1].cid = master_cid
		
		print(len(closed_edges), " ", len(open_edges))
		for i in components:
			closed_edges.append(components[i])
			open_edges.erase(components[i])
		print(len(closed_edges), " ", len(open_edges))

		# check if completed
		components = {}
		count = 0
		for i in open_edges:
			if !components.has(i.vs[0].cid):
				components[i.vs[0].cid] = null
				count += 1
		
		if count == 1:
			completed = true
	
	# now let's throw in some extra edges (NOTE: this sucks)
	# var extras = 5
	# for i in range(extras):
	# 	var index = randi() % int(len(open_edges))
	# 	closed_edges.append(open_edges[i])
	# 	open_edges.erase(open_edges[i])

	# returns a list of edges
	return closed_edges

