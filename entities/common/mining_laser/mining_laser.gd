@tool
class_name MiningLaser extends Node2D

@export var ray_cast: RayCast2D
@export var line_2d: Line2D

@export var cast_speed := 1000.0
@export var max_length := 100.0

@export var is_casting := false: set = set_is_casting
@export var color := Color.WHITE: set = set_color

func _ready() -> void:
	assert(ray_cast, "No ray cast was provided")
	assert(line_2d, "No line 2d was provided")

	set_color(color)
	set_is_casting(is_casting)

func _physics_process(delta: float) -> void:
	if is_casting == false:
		line_2d.points[1] = Vector2.ZERO
		ray_cast.target_position = Vector2.ZERO
		return

	ray_cast.target_position.x = move_toward(
		ray_cast.target_position.x,
		max_length,
		cast_speed * delta
	)
	
	var laser_end_position := ray_cast.target_position
	
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		laser_end_position = to_local(ray_cast.get_collision_point())
	
	line_2d.points[1] = laser_end_position

func set_color(new_color: Color) -> void:
	color = new_color

	line_2d.modulate = new_color

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return

	is_casting = new_value
