extends Ability
class_name FieldTestingAbility

func _init() -> void:
	ability_name = "Field Testing"
	ap_cost = 2
	adr_gain_on_use = 5.0

func execute(target: Character) -> void:
	var tier := get_current_tier()
	var status := FieldTestingEffect.new()
	status.base_duration = 1 if tier <= 1 else 4
	if tier <= 1:
		status.atk_mult_add = 0.05
		status.def_mult_add = -0.05
	elif tier == 2:
		status.atk_mult_add = 0.10
		apply_status(target, CorrosionEffect.new())
	elif tier == 3:
		status.atk_mult_add = 0.50
		target.hp -= target.max_hp * 0.5
		apply_status(target, CorrosionEffect.new())
	else:
		status.atk_mult_add = 1.0
		status.set_hp_to_one = true
		status.set_def_to_one = true
		status.invulnerable = true
		apply_status(target, CorrosionEffect.new())
	apply_status(target, status)
	ability_owner.gain_adrenaline(adr_gain_on_use)
	last_damage_done = 0.0
