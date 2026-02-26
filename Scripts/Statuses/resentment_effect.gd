extends StatusEffect
class_name ResentmentEffect

var dot_atk := 10.0

func on_apply(target: Character) -> void:
	target.status_effects.append(self)
	victim = target
	
func on_turn_start() -> void:
	victim.hp -= dot_atk
	
func on_turn_end() -> void:
	#fix the duration thing because it is not killing itself after 4 turns
	_duration = _duration - 1
	
func on_remove() -> void:
	print("exit")
	victim.status_effects.erase(self)
	queue_free()
	
