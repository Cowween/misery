extends StatusEffect
class_name StatModifierEffect

@export var atk_mult_add := 0.0
@export var atk_add_amount := 0.0
@export var def_mult_add := 0.0
@export var def_add_amount := 0.0
@export var res_mult_add := 0.0
@export var res_add_amount := 0.0
@export var speed_mult_add := 0.0
@export var speed_add_amount := 0.0
@export var ap_cost_add_amount := 0

func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)
	_apply(1)

func add_stack(amount := 1) -> void:
	super.add_stack(amount)
	_apply(amount)

func on_remove() -> void:
	if victim:
		_apply(-stacks)
	super()

func on_turn_end() -> void:
	_duration -= 1

func _apply(amount: int) -> void:
	if not victim:
		return
	victim.atk_mult += atk_mult_add * amount
	victim.atk_add += atk_add_amount * amount
	victim.def_mult += def_mult_add * amount
	victim.def_add += def_add_amount * amount
	victim.res_mult += res_mult_add * amount
	victim.res_add += res_add_amount * amount
	victim.speed_mult += speed_mult_add * amount
	victim.speed_add += speed_add_amount * amount
	victim.ap_cost_add += ap_cost_add_amount * amount
