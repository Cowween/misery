extends StatusEffect
class_name MarkOfDeliverance
"""
“Forgiveness” that clears all statuses for big damage, applies “forgiven”
Resentment + Forgiveness = hemorrhage for big damage
"""
var no_of_stacks : int
# Called when the node enters the scene tree for the first time.
func on_apply(target: Character) -> void:
	victim = target
	stacks = no_of_stacks
	target.status_effects.append(self)
	
	
func on_turn_end() -> void:
	_duration = _duration - 1
