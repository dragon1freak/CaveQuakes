extends Node

export var width : int
export var height : int
export var wall_percent : float

var cells = []
var wall_char = "#"
var floor_char = " "
var rng = RandomNumberGenerator.new()

var tile_map : TileMap

func _ready():
	self.tile_map = get_parent() as TileMap
	rng.randomize()
	clear()
	generateroomlist()
	seedRoom()
	runAutomata()
	createPlayerSpawn()
	WorldManager.level_ready()

# Generates the array used to contain the room
func generateroomlist() -> void:
	for x in height:
		cells.append([])
		for y in width:
			cells[x].append(floor_char)

func seedRoom() -> void:
	for x in height:
		for y in width:
			if rng.randf() <= wall_percent/100 and !(x in [(height / 2) - 1, height / 2, (height / 2) - 1]):
				cells[x][y] = wall_char
	

func runAutomata(iterations : int = 4) -> void: 
	var width_midpoint = width / 2
	var height_midpoint = height / 2
	while iterations > 0:
		checkQuadrant(0, width_midpoint, 0, height_midpoint)
		checkQuadrant(0, width_midpoint, height - 1, height_midpoint - 1)
		checkQuadrant(width - 1, width_midpoint - 1, 0, height_midpoint)
		checkQuadrant(width - 1, width_midpoint - 1, height - 1, height_midpoint - 1)

		iterations -= 1
	self.tile_map.update_dirty_quadrants()

func checkQuadrant(widthStart, widthEnd, heightStart, heightEnd):
	var wallsNeeded : int = 0
	for x in range(heightStart, heightEnd, -1 if heightStart > heightEnd else 1):
		for y in range(widthStart, widthEnd, -1 if widthStart > widthEnd else 1):
			var walls = 0
			wallsNeeded = 4 if cells[x][y] == wall_char else 5
			if x == heightStart or x == height - 1:
				walls = wallsNeeded
			else:
				if y == widthStart or y == width - 1:
					walls = wallsNeeded
				else:
					for i in range(x - 1, x + 2):
						for j in range(y - 1, y + 2):
							if cells[i][j] == wall_char:
								walls += 1
			if walls >= wallsNeeded:
				cells[x][y] = wall_char
				_set_autotile(y, x)
			else:
				cells[x][y] = floor_char
				_set_autotile(y, x, false)

func createPlayerSpawn():
	for x in range(height / 2 - 4, height / 2 + 4):
		for y in range(0, 5):
			_set_autotile(y, x, false)

func clear() -> void:
	self.tile_map.clear()

func _set_autotile(x : int, y : int, isWall : bool = true) -> void:
	self.tile_map.set_cell(x, y, self.tile_map.get_tileset().get_tiles_ids()[0 if isWall else 1], false, false, false, self.tile_map.get_cell_autotile_coord(x, y))
	self.tile_map.update_bitmask_area(Vector2(x, y))

func printRoom() -> void:
	for x in range(height):
		var line = ""
		for y in range(width):
			line += cells[x][y]
		print(line)
