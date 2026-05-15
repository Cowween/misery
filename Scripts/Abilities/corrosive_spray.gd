extends Ability
class_name CorrosiveSprayAbility

func _init() -> void:
	ability_name = "Corrosive Spray"
	ap_cost = 1
	uses_class_range = false
	fixed_max_range = 3
	fixed_min_range = 1
	damage_type = "metaphorical"
	scaling_stat = "int"
	adr_gain_on_use = 10.0
	tier_1_damage_bonus = -0.5
	tier_2_damage_bonus = -0.2
	tier_3_damage_bonus = 0.0
	tier_4_damage_bonus = 0.15

func execute(target: Character) -> void:
	if get_current_tier() >= 2:
		deal_damage(target)
	else:
		last_damage_done = 0.0
	var corrosion := CorrosionEffect.new()
	if get_current_tier() >= 4:
		corrosion.adr_drain_per_turn = 8.0
		apply_status(target, SpeedDownEffect.new())
	apply_status(target, corrosion)
	ability_owner.gain_adrenaline(adr_gain_on_use)
