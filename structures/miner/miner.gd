class_name Miner extends Structure

func _ready() -> void:
	super()
	self.type = "miner"
	print("Hello I'm a Miner!")

func can_place() -> bool:
	return placement_area.get_overlapping_areas().size() == 0
