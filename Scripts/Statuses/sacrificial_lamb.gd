extends StatusEffect
class_name SacrificialLamb

# Called when the node enters the scene tree for the first time.
func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)
	
	
func on_turn_end() -> void:
	_duration = _duration - 1
