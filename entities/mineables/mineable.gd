class_name Mineable extends StaticBody2D

# TODO: make type a dictionary?
@export var type: String

@export_category("Mining Data")
@export var mining_time: float = 1.0 # in seconds
@export var amount_given: int = 1

signal mining_started()
signal mining_stopped()

var is_mining: bool = false

var timer: Timer

func _ready() -> void:
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
