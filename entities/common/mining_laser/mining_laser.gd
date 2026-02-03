#@tool
class_name MiningLaser extends Line2D

@export var pulse_speed: float = 5.0
@export var max_width: float = 4.0
@export var min_width: float = 2.0
@export var color_gradient: Gradient

@export var beam_particle_rate: float = 1.0
@export var impact_particle_rate: float = 1.0

@onready var beam_particles: GPUParticles2D = $BeamParticles
@onready var impact_particles: GPUParticles2D = $ImpactParticles
@onready var start_point: Marker2D = $StartPoint
@onready var end_point: Marker2D = $EndPoint

var time: float = 0.0
var beam_length: float = 0.0
var is_active: bool = false

var target: Node2D = null : set = set_target

func _ready() -> void:
	set_particles_active(false)

	width = min_width

	if color_gradient:
		gradient = color_gradient
		
	var activate_tween = create_tween()
	activate_tween.tween_property(self, "width", max_width, 0.2).set_trans(Tween.TRANS_BACK)
	activate_tween.tween_callback(func(): is_active = true)
	activate_tween.tween_callback(func(): set_particles_active(true))

func _process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		deactivate()
		return
	
	time += delta

	start_point.global_position = Vector2.ZERO
	end_point.global_position = to_local(target.global_position)
	
	points = [start_point.position, end_point.position]
	
	beam_length = start_point.position.distance_to(end_point.position)
	
	width = min_width + (sin(time * pulse_speed) + 1.0) * 0.5 * (max_width - min_width)
	
	if gradient:
		var color_offset = sin(time * 2.0) * 0.5 + 0.5
		default_color = gradient.sample(color_offset)
	
	update_particles()

func update_particles() -> void:
	if not is_active:
		return
	
	beam_particles.position = start_point.position
	beam_particles.rotation = (end_point.position - start_point.position).angle()

	beam_particles.process_material.emission_box_extents = Vector3(2.0, beam_length * 0.5, 0)
	beam_particles.process_material.initial_velocity = beam_length * 0.3
	
	impact_particles.position = end_point.position
	
	if target and target.has_method("get_mining_progress"):
		var progress = target.get_mining_progress()
		impact_particles.amount = int(lerp(20.0, 40.0, progress))
		impact_particles.speed_scale = lerp(0.8, 1.5, progress)

func set_particles_active(active: bool) -> void:
	beam_particles.emitting = active
	impact_particles.emitting = active

	if active:
		beam_particles.restart()
		impact_particles.restart()

func set_target(new_target: Node2D):
	target = new_target

func deactivate() -> void:
	if not is_active:
		return

	is_active = false

	var deactivate_tween = create_tween()
	deactivate_tween.tween_property(self, "width", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC)
	deactivate_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	deactivate_tween.tween_callback(func(): set_particles_active(false))
	deactivate_tween.tween_callback(queue_free)

#
#@export var ray_cast: RayCast2D
#@export var line_2d: Line2D
#
#@export var cast_speed := 1000.0
#@export var max_length := 100.0
#
#@export var is_casting := false: set = set_is_casting
#@export var color := Color.WHITE: set = set_color
#
#func _ready() -> void:
	#assert(ray_cast, "No ray cast was provided")
	#assert(line_2d, "No line 2d was provided")
#
	#set_color(color)
	#set_is_casting(is_casting)
#
#func _physics_process(delta: float) -> void:
	#if is_casting == false:
		#line_2d.points[1] = Vector2.ZERO
		#ray_cast.target_position = Vector2.ZERO
		#return
#
	#ray_cast.target_position.x = move_toward(
		#ray_cast.target_position.x,
		#max_length,
		#cast_speed * delta
	#)
	#
	#var laser_end_position := ray_cast.target_position
	#
	#ray_cast.force_raycast_update()
#
	#if ray_cast.is_colliding():
		#laser_end_position = to_local(ray_cast.get_collision_point())
	#
	#line_2d.points[1] = laser_end_position
#
#func set_color(new_color: Color) -> void:
	#color = new_color
#
	#line_2d.modulate = new_color
#
#func set_is_casting(new_value: bool) -> void:
	#if is_casting == new_value:
		#return
#
	#is_casting = new_value
