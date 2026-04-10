extends StatusEffect
class_name AvariceEffect
"""
“Avarice” that applies increasing ATK as long as the some character keeps attacking the same enemy with avarice attacks in continuous turns
Restraint + Avarice = big attack boost for one turn
"""
var atk_mult := 0.2

func on_apply(target: Character) -> void:
	victim = target
	victim.atk_mult += atk_mult
	target.status_effects.append(self)
	
func add_stack(amount:=1) -> void:
	super.add_stack()
	victim.atk_mult += atk_mult * (stacks -1)
	
func on_remove() -> void:
	if victim:
		victim.atk_mult -= atk_mult * stacks
	super()
	
func on_turn_start() -> void:
	pass
	
func on_turn_end() -> void:
	_duration = _duration - 1
