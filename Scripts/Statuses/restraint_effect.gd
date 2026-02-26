extends StatusEffect
class_name RestraintEffect

var ADR_add := 1

func on_apply(target: Character) -> void:
	victim = target
	victim.adrenaline += ADR_add
	
func on_remove() -> void:
	victim.status_effects.erase(self)
	queue_free()
	
func on_turn_start() -> void:
	victim.adrenaline += ADR_add
	
func on_turn_end() -> void:
	_duration = _duration - 1
