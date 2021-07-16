extends Node


var map_width = 60.0
var map_height = 60.0

var grid = []

export var tileset: TileSet = null
export(int) var random_seed = 0


var chance_to_become_wall = 0.45

enum CellType {
	Floor,
	Wall
}


func initialize():
	
	for row in range(map_height):
		grid.append([])
		for col in range(map_width):
			if randf() < chance_to_become_wall:
				grid[row].append(CellType.Wall)
			else:
				grid[row].append(CellType.Floor)
				
func iterate():
	for row in range(map_height):
		for col in range(map_width):
			
			var nb_walls = 0
			var nb_floors = 0
			
			for i in [-1, 0, 1]:
				for j in [-1, 0, 1]:
					if i == 0 and j == 0:
						continue
					var neighbor = get_cell_at(col-i, row-j)

					if neighbor != null:

						match neighbor:
							CellType.Wall:
								nb_walls += 1
		
			
			# Now the rules.
			match grid[row][col]:
				CellType.Wall:
					if nb_walls < 3:
						grid[row][col] = CellType.Floor
				CellType.Floor:
					if nb_walls > 4:
						grid[row][col] = CellType.Wall
				


func generate():
	var map = TileMap.new()
	map.cell_size = Vector2(16, 16)
	map.tile_set = tileset
	
	for row in range(grid.size()):
		for col in range(grid[row].size()):
			match grid[row][col]:
				CellType.Floor:
					map.set_cell(row, col, tileset.find_tile_by_name("floor"))
				CellType.Wall:
					map.set_cell(row, col, tileset.find_tile_by_name("wall"))
			
	return map 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_cell_at(x, y):
	if x<0 or y<0 or y >= map_height or x >= map_width:
		return null
	else:
		return grid[y][x]
