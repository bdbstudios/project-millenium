class_name Player extends CharacterBody2D

@export var move_speed: float = 200.0

@export_category("Camera Settings")
@export var initial_zoom: float = 3.0
@export var min_zoom: float = 0.5
@export var max_zoom: float = 5.0
@export var zoom_step: float = 0.5
@export var zoom_speed: float = 5.0

@onready var camera: Camera2D = $Camera2D
@onready var look_at_anchor: Marker2D = $LookAtAnchor
@onready var mining_behavior: MiningBehavior = $Behaviors/MiningBehavior

var should_follow_cursor: bool = true
var target_zoom: float

func _ready() -> void:
	camera.zoom.x = initial_zoom
	zoom_reset()

	#mining_behavior.mining_started.connect(_on_mining_start)
	#mining_behavior.mining_stopped.connect(_on_mining_stop)

func _process(delta: float) -> void:
	if should_follow_cursor:
		look_at_anchor.global_position = get_global_mouse_position()

	look_at(look_at_anchor.global_position)

	var camera_zoom = camera.zoom.x
	
	if not is_equal_approx(camera_zoom, target_zoom):
		camera_zoom = lerp(camera_zoom, target_zoom, zoom_speed * delta)

		if abs(camera_zoom - target_zoom) < 0.01:
			camera_zoom = target_zoom

	camera.zoom = Vector2(camera_zoom, camera_zoom)

func _physics_process(_delta: float) -> void:
	var move_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	
	self.velocity = move_direction * move_speed

	self.move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom_in()

	if event.is_action_pressed("zoom_out"):
		zoom_out()

	if event.is_action_pressed("zoom_reset"):
		zoom_reset()

#func _on_mining_start(_resource: Mineable) -> void:
	#look_at_anchor.global_position = get_global_mouse_position()
	#should_follow_cursor = false
#
#func _on_mining_stop() -> void:
	#look_at_anchor.global_position = get_global_mouse_position()
	#should_follow_cursor = true

func zoom_in() -> void:
	target_zoom = clamp(target_zoom + zoom_step, min_zoom, max_zoom)

func zoom_out() -> void:
	target_zoom = clamp(target_zoom - zoom_step, min_zoom, max_zoom)

func zoom_reset() -> void:
	target_zoom = initial_zoom
