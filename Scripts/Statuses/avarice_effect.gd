extends StatusEffect
class_name AvariceEffect

var atk_mult := 0.2

func on_apply(target: Character) -> void:
	victim = target
	victim.atk_mult += atk_mult
	
func add_stack() -> void:
	super.add_stack()
	victim.atk_mult += atk_mult * (stacks -1)
	
func on_remove() -> void:
	victim.atk_mult -= atk_mult * stacks
	victim.status_effects.erase(self)
	queue_free()
	
func on_turn_start() -> void:
	pass
	
func on_turn_end() -> void:
	_duration = _duration - 1
