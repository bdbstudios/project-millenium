class_name Player extends CharacterBody2D

@export var move_speed: float = 200.0

@export var camera: Camera2D
@export var initial_zoom: float
@export var min_zoom: float = 0.5
@export var max_zoom: float = 5.0
@export var zoom_step: float = 0.5
@export var zoom_speed: float = 5.0

var target_zoom: float

func _ready() -> void:
	assert(camera, "No camera was provided")

	initial_zoom = camera.zoom.x
	zoom_reset()

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
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

func zoom_in() -> void:
	target_zoom = clamp(target_zoom + zoom_step, min_zoom, max_zoom)

func zoom_out() -> void:
	target_zoom = clamp(target_zoom - zoom_step, min_zoom, max_zoom)

func zoom_reset() -> void:
	target_zoom = initial_zoom
