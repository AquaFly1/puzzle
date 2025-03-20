extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var tile_map_layer_2: TileMapLayer = $TileMapLayer2
@onready var tile_map_layer_3: TileMapLayer = $TileMapLayer3

var offset = Vector2i(-1,0)
var can_teleport = true
var player_pos = Vector2i(10,5)
@onready var player: Sprite2D = $TileMapLayer3/player

@export var portals = []

func _ready() -> void:
	print(portals)

func _process(delta: float) -> void:
	for i in tile_map_layer_3.get_used_cells_by_id(1, Vector2i(0,0)):
		tile_map_layer_3.erase_cell(i)
	tile_map_layer_3.set_cell(player_pos, 1, Vector2i(0,0))
	player.position = tile_map_layer_3.map_to_local(player_pos)

func _input(event: InputEvent) -> void:
	var next_player_pos = player_pos
	if Input.is_action_just_pressed("down"):
		next_player_pos.y +=1
		player.rotation = PI
		offset = Vector2i(0,1)
	elif Input.is_action_just_pressed("up"):
		next_player_pos.y -=1
		player.rotation = 0
		offset = Vector2i(0,-1)
	elif Input.is_action_just_pressed("left"):
		next_player_pos.x -=1
		player.rotation = 3*PI/2
		offset = Vector2i(-1,0)
	elif Input.is_action_just_pressed("right"):
		next_player_pos.x +=1
		player.rotation = PI/2
		offset = Vector2i(1,0)
		
	if player_pos != next_player_pos:
		var id = tile_map_layer_2.get_cell_source_id(next_player_pos)
		print(id)
		next_player_pos = _teleport(next_player_pos)
		if id == 5 or id == 6:
			print("look left")
			offset = Vector2i(-1,0)
			player.rotation = 3*PI/2
		elif id == 3 or id == 8:
			print("look right")
			offset = Vector2i(1,0)
			player.rotation = PI/2
		elif id == 2 or id == 7:
			print("look up")
			offset = Vector2i(0,-1)
			player.rotation = 0
		elif id == 4 or id == 9:
			print("look down")
			offset = Vector2i(0,1)
			player.rotation = PI
		
		can_teleport = true
	if _is_valid(next_player_pos):
		player_pos = next_player_pos
		
	if Input.is_action_just_pressed("blue"):
		var id =0
		var ids = [2,3,4,6]
		for x in ids:
			for i in tile_map_layer_2.get_used_cells_by_id(x, Vector2i(0,0)):
				tile_map_layer_2.erase_cell(i)
		portals[0][0] = _find_wall()
		if offset == Vector2i(1,0): #right
			id = 6
		if offset == Vector2i(-1,0): #left
			id = 3
		if offset == Vector2i(0,1): #down
			id = 2
		if offset == Vector2i(0,-1): #up
			id = 4
		tile_map_layer_2.set_cell(_find_wall(), id, Vector2i(0,0))
		
	if Input.is_action_just_pressed("red"):
		var id = 0
		var ids = [5,7,8,9]
		for x in ids:
			for i in tile_map_layer_2.get_used_cells_by_id(x, Vector2i(0,0)):
				tile_map_layer_2.erase_cell(i)
			
		portals[0][1] = _find_wall()
		if offset == Vector2i(1,0): #right
			id = 5
		if offset == Vector2i(-1,0): #left
			id = 8
		if offset == Vector2i(0,1): #down
			id = 7
		if offset == Vector2i(0,-1): #up
			id = 9
		tile_map_layer_2.set_cell(_find_wall(), id, Vector2i(0,0))

func _is_valid(pos):
	return pos not in tile_map_layer_2.get_used_cells_by_id(0, Vector2i(0,0))

func _teleport(next_player_pos):
	for i in portals:
		if next_player_pos == i[0]:
			next_player_pos = i[1]
			can_teleport = false
		elif next_player_pos == i[1]:
			next_player_pos = i[0]
			can_teleport = false
	return next_player_pos

func _find_wall():
	var positions = []
	var portal_pos = _find_next_tile(offset, player_pos, positions)
	return portal_pos

func _find_next_tile(offset, current_pos, positions):
	var x = 0
	for i in range(100):
		positions.append(null)
	while _is_valid(current_pos):
		positions[x] = current_pos
		current_pos += offset
		x +=1
	return current_pos - offset
	
