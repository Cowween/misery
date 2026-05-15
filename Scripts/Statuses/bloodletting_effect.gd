extends StatModifierEffect
class_name BloodlettingEffect

@export var adr_on_hit := 12.0
@export var damage_stack_bonus := 0.05
@export var max_damage_stacks := 5
var damage_stacks := 0

func _init() -> void:
	status_name = "Bloodletting"
	base_duration = 2
	def_mult_add = 0.25
	texture = Color(0.65, 0.0, 0.05, 1.0)

func add_damage_stack(character: Character) -> void:
	if damage_stacks >= max_damage_stacks:
		return
	damage_stacks += 1
	character.atk_mult += damage_stack_bonus

func on_remove() -> void:
	if victim:
		victim.atk_mult -= damage_stack_bonus * damage_stacks
	super()
