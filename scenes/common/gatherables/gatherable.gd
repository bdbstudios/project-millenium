class_name Gatherable extends Node2D

@export var static_body: StaticBody2D

func _ready() -> void:
	assert(static_body, "No static body was provided")

	static_body.input_pickable = true
	static_body.input_event.connect(on_input_event)

func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("fire"):
		print("SELECT GATHERABLE: ", name)
