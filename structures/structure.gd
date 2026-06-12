class_name Structure extends StaticBody2D

var type: String

@onready var placement_area: Area2D = $PlacementArea

func _ready() -> void:
	assert(placement_area, "No placement area detected for structure")

func can_place() -> bool:
	return placement_area.get_overlapping_areas().size() == 0
