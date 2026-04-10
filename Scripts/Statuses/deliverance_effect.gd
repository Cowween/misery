extends StatusEffect
class_name DeliveranceEffect

"""
“Deliverance” that sacrifices a large amount of AP that carries throughout turns for big damage
Sacrifice + Deliverance = Convert AP into HP for the amount of sacrifice stacks on the enemy
"""
@export var ap_cost_per_stack := 5
@export var atk_mult_per_stack := 4

var ap_cost := 0
var atk_mult := 0
func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)
	atk_mult = atk_mult_per_stack * stacks
	victim.atk_mult += atk_mult
	ap_cost = stacks * ap_cost_per_stack
	on_turn_start()

func on_turn_start() -> void:
	if victim:
		# Consume AP, allowing it to go into deficit (carrying over turns)
		if ap_cost > victim.action_points:
			ap_cost -= victim.action_points
			victim.action_points = 0
			stacks = ceili(float(ap_cost)/ap_cost_per_stack)
		else:
			victim.action_points -= ap_cost
			on_remove()
		

func add_stack(amount:=1) -> void:
	pass

func on_remove() -> void:
	if victim:
		victim.atk_mult -= atk_mult
	super()
	
