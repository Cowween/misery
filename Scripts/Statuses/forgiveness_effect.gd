extends StatusEffect
class_name ForgivenessEffect

@export var atk := 10.0

# Called when the node enters the scene tree for the first time.
func on_apply(target: Character) -> void:
	victim = target
	var no_of_statuses = victim.status_effects.size()
	for i in victim.status_effects:
		i.on_remove()
	victim.hp -= no_of_statuses * atk
	
func on_remove() -> void:
	victim.status_effects.erase(self)
	queue_free()
	
func on_turn_start() -> void:
	_duration = _duration - 1
	
func on_turn_end() -> void:
	pass
