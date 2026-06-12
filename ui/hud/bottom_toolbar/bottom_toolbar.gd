class_name BottomToolbar extends CanvasLayer

signal structure_selected(structure_scene: PackedScene)

@onready var h_box_container: HBoxContainer = $PanelContainer/HBoxContainer

@onready var core_scene = preload("res://structures/core/Core.tscn")
@onready var miner_scene = preload("res://structures/miner/Miner.tscn")

var player: Player

var active_slot_index: int = -1
var hotbar_slots: Array = [null, null, null, null, null]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	assert(player, "Not able to get the player")
	
	hotbar_slots[0] = core_scene
	hotbar_slots[1] = miner_scene
	
	var buttons = h_box_container.get_children()

	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_slot_pressed.bind(i))

func _on_slot_pressed(slot_index: int) -> void:
	select_slot(slot_index)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hotbar_1"):
		select_slot(0)
	
	if event.is_action_pressed("hotbar_2"):
		select_slot(1)
		
	if event.is_action_pressed("hotbar_3"):
		select_slot(2)
		
	if event.is_action_pressed("hotbar_4"):
		select_slot(3)
		
	if event.is_action_pressed("hotbar_5"):
		select_slot(4)

func select_slot(slot_index: int) -> void:
	var selected_scene = hotbar_slots[slot_index]

	if selected_scene != null:
		if active_slot_index == slot_index:
			active_slot_index = -1
			player.building_placement_manager.cancel_placement_mode()
		else:
			active_slot_index = slot_index
			structure_selected.emit(selected_scene)
			player.building_placement_manager.enter_placement_mode(selected_scene)
	else:
		active_slot_index = -1
		print("Slot ", slot_index + 1, " is currently empty!")
