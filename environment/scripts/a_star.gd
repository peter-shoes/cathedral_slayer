class StarNode:
	var loc: Vector2
	var end: Vector2
	var g: int
	var h: int
	var f: int
	var parent: StarNode

	func _init(l, e, p = null):
		self.loc = l
		self.end = e
		if p:
			self.parent = p
			self.g = self.parent.g+1
		else:
			self.g = 0
		self.calc_h()
		self.calc_f()
	
	func calc_h():
		var gx = abs(self.loc.x-self.end.x)
		var gy = abs(self.loc.y-self.end.y)
		self.h = pow(gx,2)+pow(gy,2)
	
	func calc_f():
		self.f = self.g+self.h

func calc_a_star(start, end, map):
	print("a_star called")
	var open = []
	var closed = []
	var start_node = StarNode.new(start, end)
	open.append(start_node)
	var tries = 0
	while tries < 1000:
		# find the lowest f node
		var lowest_f_node = null
		var f_index = null
		if len(open) == 0:
			push_error("no nodes in open array")
		for node in range(len(open)):
			if !lowest_f_node or lowest_f_node.f > open[node].f:
				lowest_f_node = open[node]
				f_index = node
		# switch it from the open to closed list
		open.remove(f_index)
		closed.append(lowest_f_node)
		var n = StarNode.new(lowest_f_node.loc + Vector2.UP, end, lowest_f_node)
		var s = StarNode.new(lowest_f_node.loc + Vector2.DOWN, end, lowest_f_node)
		var e = StarNode.new(lowest_f_node.loc + Vector2.RIGHT, end, lowest_f_node)
		var w = StarNode.new(lowest_f_node.loc + Vector2.LEFT, end, lowest_f_node)
		var neighbors = [n,s,e,w]
		for neighbor in neighbors:
			if map.get_cellv(neighbor.loc) == -1 and !closed.has(neighbor):
				# for index in range(len(open)-1):
				# 	print(index)
				# 	if open[index].loc == neighbor.loc:
				# 		if open[index].g > neighbor.g:
				# 			open.remove(index)
				open.append(neighbor)
			if neighbor.loc == end:
				var path = []
				var cur = neighbor
				while cur.g != 0:
					path.append(cur.loc)
					cur = cur.parent
				path.append(cur.loc)
				print(path)
				return path
		tries += 1
	print("returning start")
	return [start]
