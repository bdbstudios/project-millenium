class_name Mineable extends Node2D

# TODO: make type a dictionary?
@export var type: String

@export_category("Node Assignments")
@export var static_body: StaticBody2D

@export_category("Mining Data")
@export var mining_time: float = 1.0 # in seconds
@export var amount_given: int = 1

signal mining_started()
signal mining_stopped()

var is_mining: bool = false

var timer: Timer

func _ready() -> void:
	assert(static_body, "No static body was provided")

	static_body.input_pickable = true # Make sure every mineable emits "input_event" signal
	static_body.input_event.connect(_on_area_input)
	
	timer = Timer.new()
	timer.timeout.connect(_on_mining_tick)
	add_child(timer)

func start_mining() -> void:
	if is_mining:
		stop_mining()

	timer.start(mining_time)

	is_mining = true
	mining_started.emit()
	print("Start")

func stop_mining() -> void:
	timer.stop()

	is_mining = false
	mining_stopped.emit()
	print("Stop")

func _on_mining_tick() -> void:
	print("Tick (add resource ", type ," x", amount_given ,")")

# TODO: this should be done by the player script, not the mineable
func _on_area_input(_viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if event.is_action_pressed("select"):
		start_mining()

# TODO: this should be done by the player script, not the mineable
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select") or event.is_action_pressed("cancel"):
		stop_mining()
