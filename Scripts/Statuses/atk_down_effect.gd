extends StatModifierEffect
class_name AtkDownEffect

func _init() -> void:
	status_name = "Attack Down"
	base_duration = 2
	atk_mult_add = -0.2
	texture = Color(0.5, 0.5, 0.6, 1.0)
