# Scripts/Statuses/sacrifice_effect.gd
extends StatusEffect
class_name SacrificeEffect

@export var hp_cost_per_stack := 20
@export var atk_mult_per_stack := 1.5

var atk_mult := 0
func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)
	atk_mult = atk_mult_per_stack * stacks
	victim.atk_mult += atk_mult
	on_turn_start()

func on_turn_start() -> void:
	if victim:
		victim.hp -= hp_cost_per_stack * stacks
		

func add_stack(amount:=1) -> void:
	super(amount)
	victim.atk_mult -= atk_mult
	atk_mult = atk_mult_per_stack * stacks
	victim.atk_mult += atk_mult

func on_remove() -> void:
	if victim:
		victim.atk_mult -= atk_mult
	super()
	
func on_turn_end() -> void:
	_duration = _duration -1
