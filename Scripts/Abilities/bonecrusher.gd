extends Ability
class_name BonecrusherAbility

func _init() -> void:
	ability_name = "Bonecrusher"
	ap_cost = 1
	scaling_stat = "str"
	adr_gain_on_use = 12.0
	tier_1_damage_bonus = 0.25
	tier_2_damage_bonus = 0.35
	tier_3_damage_bonus = 0.5
	tier_4_damage_bonus = 1.0
	tier_2_extra_hits = 1
	tier_3_extra_hits = 2
	tier_4_extra_hits = 2

func execute(target: Character) -> void:
	deal_damage(target)
	if not is_instance_valid(target):
		return
	if get_current_tier() >= 3:
		apply_status(target, SpeedDownEffect.new())
	if get_current_tier() >= 4:
		apply_status(target, VulnerabilityEffect.new())
