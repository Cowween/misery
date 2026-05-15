extends StatModifierEffect
class_name SpeedDownEffect

func _init() -> void:
	status_name = "Speed Down"
	base_duration = 2
	speed_mult_add = -0.25
	texture = Color(0.35, 0.55, 1.0, 1.0)
