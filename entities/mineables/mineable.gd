class_name Mineable extends Resource

# TODO: make resource type a dictionary?
@export var resource_type: String

@export_category("Visuals")
@export var texture: Texture2D
@export var label: String

@export_category("Mining Data")
@export var mining_time: float = 1.0 # in seconds
@export var amount_given: int = 1
