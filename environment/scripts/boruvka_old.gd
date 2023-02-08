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



func calc_mst_boruvka(rooms: Array, r: bool = false):
	var vectors = []
	var components = {}
	var closed_edges = []
	var open_edges = []
	var delaunay = null
	var precalc_edges = []
	var count = 0

	# recursive check
	if !r:
		# get delaunay edges before beginning
		var center_array = PoolVector2Array()
		for room in rooms:
			center_array.append(room.center)
		
		delaunay = Geometry.triangulate_delaunay_2d(center_array)
		if ! delaunay or len(delaunay) == 0:
			return []
		
		# this has given us which ROOMS are connected, but we need to find the edges
		# just realized we can do this recursively
		
		for i in range(0,len(delaunay), 3):
			var sub_edges = calc_mst_boruvka(
				[
					rooms[delaunay[i]],
					rooms[delaunay[i+1]],
					rooms[delaunay[i+2]],
				], true
			)
			for j in sub_edges:
				precalc_edges.append(j)
		 
		
		
	# assign each room to a connected component
	# add components to list
	for room in rooms:
		vectors.append(Vector.new(room.door_n, count))
		vectors.append(Vector.new(room.door_s, count))
		vectors.append(Vector.new(room.door_e, count))
		vectors.append(Vector.new(room.door_w, count))
		components[count] = null
		count += 1
	
	# recursive, working from scratch
	if r:
		for i in vectors:
			for j in vectors:
				if i.cid != j.cid:
					open_edges.append(Edge.new(i,j))
	# not recursive, parent call
	else:
		for edge in precalc_edges:
			var v1 = null
			var v2 = null
			for i in vectors:
				if i.v == edge.vs[0].v:
					v1 = i
				elif i.v == edge.vs[1].v:
					v2 = i
			if v1 and v2:
				open_edges.append(Edge.new(v1, v2))
			else:
				push_error("Vector not found")


	
	var completed = false
	while !completed:
	
		#get lowest edges for each component
		for i in components:
			for j in open_edges:
				if j.vs[0].cid == i or j.vs[1].cid == i:
					if !components[i] or components[i].weight > j.weight:
						components[i] = j		
		
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
		
		for i in components:
			closed_edges.append(components[i])
			open_edges.erase(components[i])

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

