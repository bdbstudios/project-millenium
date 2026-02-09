class_name MiningBehavior extends Node

#signal mining_started(resource: Mineable)
#signal mining_stopped()
#
#var is_mining: bool = false
#var target_resource: Mineable
#var tile_map_layer: TileMapLayer
#
#var timer: Timer
#var marker: Marker2D
#
#func _ready() -> void:
	#tile_map_layer = get_tree().get_first_node_in_group("tile_map_mineables")
#
	#assert(tile_map_layer, "No tile map layer was found")
#
	#timer = Timer.new()
	#timer.timeout.connect(_on_mining_tick)
	#add_child(timer)
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("select"):
		#select_cell()
#
	#if event.is_action_pressed("cancel"):
		#deselect_cell()
#
#func select_cell() -> void:
	#var target_coords = tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())
	#var cell_data = tile_map_layer.get_cell_tile_data(target_coords)
	#
	#print(cell_data)
#
	#if not cell_data:
		#target_resource = null
		#return
		#
	#target_resource = cell_data.get_custom_data("resource_type")
	#
	#if not target_resource:
		#return
#
	#start_mining()
#
#func start_mining() -> void:
	#if is_mining:
		#stop_mining()
#
	#timer.start(target_resource.mining_time)
#
	#is_mining = true
	#mining_started.emit(target_resource)
	#print("Start")
#
#func stop_mining() -> void:
	#timer.stop()
#
	#is_mining = false
	#mining_stopped.emit()
	#print("Stop")
#
#func deselect_cell() -> void:
	#stop_mining()
#
#func _on_mining_tick() -> void:
	#print("Tick (add resource ", target_resource.label ," x", target_resource.amount_given ,")")






























## TODO: update player script to connect everything together
#
##signal mining_started(resource: Node2D)
##signal mining_stopped()
##signal mining_progress(progress: float, resource_type: String)
#
#@export var mining_range: float = 10.0
#@export var mining_speed: float = 1.0



#@export var laser_anchor: Marker2D
#@export var character_body: CharacterBody2D
#@export var mining_laser_scene: PackedScene
#
#var current_target: Node2D = null
#var mining_laser_instance: Node2D = null
#var is_mining: bool = false
#var mining_timer: Timer
#var resource_type_cache: String = ""
#
#func _ready():
	#assert(laser_anchor, "No laser anchor was provided")
	#assert(character_body, "No character body was provided")
	#assert(mining_laser_scene, "No mining laser scene was provided")
	#
	#mining_timer = Timer.new()
	#mining_timer.wait_time = 1.0 / mining_speed
	#mining_timer.timeout.connect(_on_mining_tick)
	#add_child(mining_timer)
#
#func _process(_delta: float):
	#if is_mining and current_target:
		#if mining_laser_instance:
			#mining_laser_instance.look_at(current_target.global_position)
#
		#var distance = character_body.global_position.distance_to(current_target.global_position)
		#if distance > mining_range:
			#stop_mining("out_of_range")
#
#func start_mining(new_target: Node2D) -> void:
	#if is_mining:
		#stop_mining("switching_target")
#
	#current_target = new_target
	#is_mining = true
	#
	#var mineable = new_target.get_node_or_null("MineableComponent")
	#if not mineable:
		#push_error("Target doesn't have MineableComponent")
		#return
#
	#resource_type_cache = mineable.resource_type
#
	#mining_laser_instance = mining_laser_scene.instantiate()
	#laser_anchor.add_child(mining_laser_instance)
	#mining_laser_instance.target = new_target
#
	#mining_timer.start()
	#mining_started.emit(new_target)
#
#func stop_mining(reason: String = "manual") -> void:
	#if not is_mining:
		#return
#
	#is_mining = false
#
	#if mining_laser_instance:
		#mining_laser_instance.queue_free()
		#mining_laser_instance = null
#
	#mining_timer.stop()
#
	#current_target = null
#
	#mining_stopped.emit()
#
	#print("Mining stopped: ", reason)
#
#func cancel_mining() -> void:
	#stop_mining("cancelled")
#
#func _on_mining_tick() -> void:
	#if not is_mining or not current_target:
		#return
	#
	#var mineable = current_target.get_node("MineableComponent")
	#if not mineable:
		#stop_mining("target_invalid")
		#return
	#
	#var mined_amount = mineable.mine(1, character_body)
	#
	#if mined_amount > 0:
		#mining_progress.emit(mineable.get_progress(), resource_type_cache)
#
		#EventBus.show_notification.emit(
			#"+%d %s" % [mined_amount, resource_type_cache],
			#"resource"
		#)
	#else:
		#stop_mining("resource_depleted")
#
#func _on_selected_resource(selected_target: Node2D) -> void:
	#var mineable = selected_target.get_node_or_null("MineableComponent")
#
	#if mineable:
		#start_mining(selected_target)
	#else:
		#stop_mining("new_target_not_mineable")
