extends Ability
class_name SentinelAbility

func _init() -> void:
	ability_name = "Sentinel"
	ap_cost = 2
	adr_gain_on_use = 5.0

func execute(target: Character) -> void:
	var tier := get_current_tier()
	if target and tier >= 3:
		apply_status(target, AtkDownEffect.new())
	if ability_owner:
		ability_owner.class_state["sentinel_threat"] = 1.25 + 0.25 * tier
		ability_owner.class_state["sentinel_range"] = ability_range.max_range if ability_range else ability_owner.atk_range
	ability_owner.gain_adrenaline(adr_gain_on_use)
	last_damage_done = 0.0
