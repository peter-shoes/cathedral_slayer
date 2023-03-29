extends GridMap

# enable navigation mesh for grid items
#set_bake_navigation(true)

func _re():
	# get mesh from grid item, bake and set a new navigation mesh for the library
	var gridmap_item_list = mesh_library.get_item_list()
	for item in gridmap_item_list:
		var item_mesh: Mesh = mesh_library.get_item_mesh(item)
		var new_item_navigation_mesh: NavigationMesh = NavigationMesh.new()
		new_item_navigation_mesh.create_from_mesh(item_mesh)
		mesh_library.set_item_navmesh(item, new_item_navigation_mesh)
		mesh_library.set_item_navmesh_transform(item, transform)
		

# add procedual cells using the first item
#var _position: Vector3i = Vector3i(global_transform.origin)
#var _item: int = 0
#var _orientation: int = 0
#for i in range(0,10):
#	for j in range(0,10):
#		_position.x = i
#		_position.z = j
#		gridmap.set_cell_item(_position, _item, _orientation)
#		_position.x = -i
#		_position.z = -j
#		gridmap.set_cell_item(_position, _item, _orientation)
