class_name BuildingPlacementManager extends Node2D

@export var color_valid = Color(0.2, 1.0, 0.2, 0.6)
@export var color_invalid = Color(1.0, 0.2, 0.2, 0.6)

var player: Player
var tile_map_structures: TileMapLayer

var is_active: bool = false
var ghost_preview: Structure = null
var selected_scene: PackedScene = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	tile_map_structures = get_tree().get_first_node_in_group("tile_map_structures")
	
	assert(player, "Not able to get the player")
	assert(tile_map_structures, "Not able to get the tile map")

func _process(_delta: float) -> void:
	if not is_active or not ghost_preview:
		return

	ghost_preview.global_position = player.selection.global_position

	if ghost_preview.can_place():
		ghost_preview.modulate = color_valid
	else:
		ghost_preview.modulate = color_invalid

func enter_placement_mode(structure_scene: PackedScene) -> void:
	cancel_placement_mode()
	
	selected_scene = structure_scene
	ghost_preview = selected_scene.instantiate() as Structure
	
	tile_map_structures.add_child(ghost_preview)
	is_active = true

func cancel_placement_mode() -> void:
	if ghost_preview:
		ghost_preview.queue_free()
		ghost_preview = null

	selected_scene = null
	is_active = false

func place_structure() -> void:
	if not ghost_preview or not selected_scene:
		return

	if ghost_preview.can_place():
		var real_building = selected_scene.instantiate() as Structure
		real_building.global_position = ghost_preview.global_position
		
		tile_map_structures.add_child(real_building)
		
		# For an automated game loop, keeping it active lets players chain build.
		# If you want single placements, uncomment the cancellation line below:
		# cancel_placement_mode()
	else:
		print("Placement rule broken. Blocked!")
