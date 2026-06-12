class_name BuildingPlacementManager extends Node2D

@export var color_valid = Color(0.2, 1.0, 0.2, 0.6)
@export var color_invalid = Color(1.0, 0.2, 0.2, 0.6)

# TODO: have this parameter be different per structure?
const REMOVAL_HOLD_TIME: float = 0.5 # 500 milliseconds in seconds

var player: Player
var bottom_toolbar: BottomToolbar
var tile_map_structures: TileMapLayer

var is_active: bool = false
var removal_timer: float = 0.0
var is_holding_remove: bool = false
var ghost_preview: Structure = null
var selected_scene: PackedScene = null
var target_structure_to_remove: Structure = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	bottom_toolbar = get_tree().get_first_node_in_group("bottom_toolbar")
	tile_map_structures = get_tree().get_first_node_in_group("tile_map_structures")
	
	assert(player, "Not able to get the player")
	assert(tile_map_structures, "Not able to get the tile map")

func _process(delta: float) -> void:
	if is_holding_remove:
		if is_instance_valid(target_structure_to_remove) and is_mouse_still_over_target():
			removal_timer += delta

			# var progress_percent = deletion_timer / REMOVAL_HOLD_TIME

			if removal_timer >= REMOVAL_HOLD_TIME:
				execute_removal()
		else:
			cancel_removal_hold()
	
	if not is_active or not ghost_preview:
		return

	ghost_preview.global_position = player.selection.global_position

	if ghost_preview.can_place():
		ghost_preview.modulate = color_valid
	else:
		ghost_preview.modulate = color_invalid

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if is_active:
			place_structure()
	
	if event.is_action_pressed("cancel"):
		if is_active:
			cancel_placement_mode()
		else:
			start_removal_hold()
	
	if event.is_action_released("cancel"):
		if is_holding_remove:
			cancel_removal_hold()

func start_removal_hold() -> void:
	var overlapping_areas = player.selection.get_overlapping_areas()
	
	for area in overlapping_areas:
		var structure = area.get_parent()
		
		if structure and structure.is_in_group("structures"):
			target_structure_to_remove = structure
			removal_timer = 0.0
			is_holding_remove = true
			return

func cancel_removal_hold() -> void:
	is_holding_remove = false
	target_structure_to_remove = null
	removal_timer = 0.0

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

	bottom_toolbar.active_slot_index = -1
	
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

func execute_removal() -> void:
	if is_instance_valid(target_structure_to_remove):
		target_structure_to_remove.queue_free()
		cancel_removal_hold()

func is_mouse_still_over_target() -> bool:
	var overlapping_areas = player.selection.get_overlapping_areas()

	for area in overlapping_areas:
		if area.get_parent() == target_structure_to_remove:
			return true

	return false
