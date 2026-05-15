extends Ability
class_name BreachAbility

func _init() -> void:
	ability_name = "Breach"
	ap_cost = 3
	uses_class_range = false
	fixed_max_range = 2
	fixed_min_range = 1
	scaling_stat = "dex"
	adr_gain_on_use = 6.0
	tier_1_damage_bonus = -0.25
	tier_2_damage_bonus = -0.1
	tier_3_damage_bonus = 0.1
	tier_4_damage_bonus = 0.35
	tier_1_range_bonus = 1
	tier_2_range_bonus = 2
	tier_3_range_bonus = 3
	tier_4_range_bonus = 5

func execute(target: Character) -> void:
	deal_damage(target)
	if get_current_tier() >= 4 and not is_instance_valid(target):
		ability_owner.action_points += get_ap_cost()
