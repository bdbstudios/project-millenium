class_name Selection extends Area2D

signal selection_changed(new_selection: Node2D)
signal selection_cleared()

var player: Player
var selected_tile: Node2D
var tile_map: TileMapLayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	tile_map = get_tree().get_first_node_in_group("tile_map_terrain")
	
	assert(player, "Not able to get the player")
	assert(tile_map, "Not able to get the tile map")

func _process(_delta: float) -> void:
	if not selected_tile:
		self.global_position = tile_map.map_to_local(tile_map.local_to_map(get_global_mouse_position()))
	else:
		if get_distance_to_player() > player.selection_range:
			clear_selection()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if not selected_tile:
			select_overlapping()
	
	if event.is_action_pressed("cancel"):
		if selected_tile:
			clear_selection()

func select_overlapping() -> void:
	# Since we snap the selection to the grid, it can only collide with one selectable
	# entity at a time
	# TODO: check if this works at scale?
	
	var overlapping_bodies = self.get_overlapping_bodies()
	
	if not overlapping_bodies:
		selected_tile = null
		return
	
	selected_tile = overlapping_bodies[0]
	selection_changed.emit(selected_tile)
	
	# TODO: maybe have a base "Selectable" that has a "trigger" function?
	# - a Mineable trigger would be "start_mining"?
	# - a structure trigger would be "open_dialog"?
	if selected_tile is Mineable:
		selected_tile.start_mining()

func clear_selection() -> void:
	if selected_tile is Mineable:
		selected_tile.stop_mining()
	
	selected_tile = null
	selection_cleared.emit()

func get_distance_to_player() -> float:
	# We divide by 16 to get an estimate number of tiles (each tile is 16x16 pixels)
	return ceilf(player.global_position.distance_to(self.global_position) / 16)
