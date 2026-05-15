extends Ability
class_name ExecutionAbility

func _init() -> void:
	ability_name = "Execution"
	ap_cost = 1
	scaling_stat = "dex"
	adr_gain_on_use = 10.0
	tier_1_damage_bonus = -0.15
	tier_2_damage_bonus = 0.0
	tier_3_damage_bonus = 0.25
	tier_4_damage_bonus = 0.45
	tier_2_extra_hits = 2
	tier_3_extra_hits = 4
	tier_4_extra_hits = 5

func execute(target: Character) -> void:
	var tier := get_current_tier()
	var damage := deal_damage(target)
	if not is_instance_valid(target):
		return
	if tier >= 3:
		apply_status(target, VulnerabilityEffect.new())
	elif tier == 2 and damage > 0.0 and get_hit_count() >= 3:
		apply_status(target, VulnerabilityEffect.new())
	if tier >= 4:
		var replay_damage := last_damage_done * 0.5
		last_damage_done += target.take_damage(replay_damage, ability_owner, "physical", false)
	ability_owner.gain_adrenaline(5.0 * max(0, get_hit_count() - 1))
