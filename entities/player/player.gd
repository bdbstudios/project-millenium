class_name Player extends CharacterBody2D

@export_category("Player Stats")
@export var selection_range: float = 10.0 # In Tiles (16x16)
@export var base_max_speed : float = 300.0
@export var base_acceleration : float = 15.0
@export var base_friction : float = 10.0
@export var speed_weight_factor: float = 0.5
@export var acceleration_weight_factor: float = 0.7
@export var friction_weight_factor: float = 0.8

@export_category("Camera Settings")
@export var initial_zoom: float = 3.0
@export var min_zoom: float = 0.5
@export var max_zoom: float = 5.0
@export var zoom_step: float = 0.5
@export var zoom_speed: float = 5.0

# TODO: hotbar manager to get which scenes should be placeable?
@export_category("Hotbar (TEMP)")
@export var core_scene: PackedScene = preload("res://entities/selectables/structures/core/Core.tscn")

@onready var camera: Camera2D = $Camera2D
@onready var selection: Selection = $Components/Selection
@onready var building_placement_manager: BuildingPlacementManager = $Components/BuildingPlacementManager

var target_zoom: float

var current_cargo_weight : float = 0.0  # Scale from 0.0 to 1.0 (Full)

func _ready() -> void:
	camera.zoom.x = initial_zoom
	zoom_reset()

func _process(delta: float) -> void:
	# Only look at something when we interact with it?
	#look_at(selection.global_position)

	var camera_zoom = camera.zoom.x
	
	if not is_equal_approx(camera_zoom, target_zoom):
		camera_zoom = lerp(camera_zoom, target_zoom, zoom_speed * delta)

		if abs(camera_zoom - target_zoom) < 0.01:
			camera_zoom = target_zoom

	camera.zoom = Vector2(camera_zoom, camera_zoom)

func _physics_process(_delta: float) -> void:
	var max_speed = base_max_speed * (1.0 - (current_cargo_weight * speed_weight_factor))
	var acceleration = base_acceleration * (1.0 - (current_cargo_weight * acceleration_weight_factor))
	var friction = base_friction * (1.0 - (current_cargo_weight * friction_weight_factor))

	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector != Vector2.ZERO:
		self.rotation = input_vector.angle()
		self.velocity = velocity.move_toward(input_vector * max_speed, acceleration)
	else:
		self.velocity = velocity.move_toward(Vector2.ZERO, friction)

	self.move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom_in()

	if event.is_action_pressed("zoom_out"):
		zoom_out()

	if event.is_action_pressed("zoom_reset"):
		zoom_reset()
		
	if event.is_action_pressed("hotbar_1"):
		if building_placement_manager.is_active:
			building_placement_manager.cancel_placement_mode()
		else:
			building_placement_manager.enter_placement_mode(core_scene)
	
	if event.is_action_pressed("select"):
		if building_placement_manager.is_active:
			building_placement_manager.place_structure()
	
	if event.is_action_pressed("cancel"):
		if building_placement_manager.is_active:
			building_placement_manager.cancel_placement_mode()

func zoom_in() -> void:
	target_zoom = clamp(target_zoom + zoom_step, min_zoom, max_zoom)

func zoom_out() -> void:
	target_zoom = clamp(target_zoom - zoom_step, min_zoom, max_zoom)

func zoom_reset() -> void:
	target_zoom = initial_zoom
