extends StatModifierEffect
class_name FieldTestingEffect

@export var set_hp_to_one := false
@export var set_def_to_one := false
@export var invulnerable := false
var _def_add_adjustment := 0.0

func _init() -> void:
	status_name = "Field Testing"
	base_duration = 4
	texture = Color(0.8, 0.2, 0.95, 1.0)

func on_apply(target: Character) -> void:
	super.on_apply(target)
	if set_hp_to_one:
		target.hp = 1.0
	if set_def_to_one:
		_def_add_adjustment = -(target.def - 1.0)
		target.def_add += _def_add_adjustment
	if invulnerable:
		target.invulnerable_turns = max(target.invulnerable_turns, base_duration)

func on_remove() -> void:
	if victim:
		victim.def_add -= _def_add_adjustment
	super()
