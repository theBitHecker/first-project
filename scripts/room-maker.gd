extends Node2D

var grid_width = 5
var grid_height = 5


var rooms = {
	'hallway': preload("res://scenes/rooms/hallway.tscn"),
	'start_stair': preload("res://scenes/rooms/start-stair.tscn"),
	'end_stair': preload("res://scenes/rooms/end-stair.tscn")
}


func generate_maze_list(start_pos: Vector2i):
	var grid = []
	var visited_cells = []
	var cell_stack = [start_pos]
	var directions = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	
	# Make grid
	for x in grid_width:
		grid.append([])
		visited_cells.append([])
		for y in grid_height:
			grid[x].append([false, false, false, false])
			visited_cells[x].append(false)

	visited_cells[start_pos.x][start_pos.y] = true
	
	while cell_stack.size() > 0:
		var current_cell = cell_stack[-1]
		var valid_neighbors = []
		
		# find neighbor cells
		for i in 4:
			var neighbor_pos = current_cell + directions[i]
			if neighbor_pos.x >= 0 and neighbor_pos.x < grid_width \
			and neighbor_pos.y >= 0 and neighbor_pos.y < grid_height \
			and !visited_cells[neighbor_pos.x][neighbor_pos.y]:
				valid_neighbors.append({"pos": neighbor_pos, "dir_index": i})
		
		# pick a cell and add it to grid
		if valid_neighbors.size() > 0:
			var choice = valid_neighbors.pick_random()
			var next_cell = choice["pos"]
			var dir_idx = choice["dir_index"]
			
			grid[current_cell.x][current_cell.y][dir_idx] = true
			grid[next_cell.x][next_cell.y][(dir_idx + 2) % 4] = true
			
			visited_cells[next_cell.x][next_cell.y] = true
			cell_stack.append(next_cell)
		else:
			cell_stack.pop_back()
			
	# remove dead ends
	for x in grid_width:
		for y in grid_height:

			if grid[x][y].count(true) == 1:
				var closed_doors = []
				
				for i in 4:
					var neighbor = Vector2i(x, y) + directions[i]
					
					if neighbor.x in range(grid_width) and neighbor.y in range(grid_height):
						if not grid[x][y][i]:
							closed_doors.append(i)
				
				if not closed_doors.is_empty():
					var dir_to_open = closed_doors.pick_random()
					var neighbor = Vector2i(x, y) + directions[dir_to_open]
					
					grid[x][y][dir_to_open] = true
					grid[neighbor.x][neighbor.y][(dir_to_open + 2) % 4] = true
	return grid
			
		
func instantiate_maze(grid: Array, start_pos: Vector2i, end_pos: Vector2i):
	var instantiated_grid = []
	for x in grid_width:
		instantiated_grid.append([])
		for y in grid_height:
			
			var cell_instance: Node2D = null
			if Vector2i(x, y) == start_pos:
				cell_instance = rooms['start_stair'].instantiate()
			elif Vector2i(x, y) == end_pos:
				cell_instance = rooms['end_stair'].instantiate()
			else:
				cell_instance = rooms['hallway'].instantiate()

			if cell_instance.has_method("set_doors"):
				cell_instance.set_doors(grid[x][y], Vector2i(x, y))
			
			cell_instance.position = Vector2(x*1500, y*1500)
			
			instantiated_grid[x].append(cell_instance)
			add_child(cell_instance)
			

func _ready():
	instantiate_maze(generate_maze_list(Vector2i(0, 0)), Vector2i(0, 0), Vector2i(4, 4))
	
func end_level(end_stair):
	var start_pos = end_stair.room_position
	print(start_pos)
	for room in get_children():
		room.queue_free()
	instantiate_maze(generate_maze_list(start_pos), start_pos, Vector2i(randi() % 4, randi() % 4))
