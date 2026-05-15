extends Ability
class_name BloodlettingAbility

func _init() -> void:
	ability_name = "Bloodletting"
	ap_cost = 3
	adr_gain_on_use = 0.0

func execute(target: Character) -> void:
	var status := BloodlettingEffect.new()
	var tier := get_current_tier()
	status.base_duration = 2 if tier <= 1 else 4
	if tier >= 2:
		status.res_mult_add = 0.2
	if tier <= 1:
		status.speed_mult_add = -0.15
	apply_status(ability_owner, status)
	last_damage_done = 0.0
