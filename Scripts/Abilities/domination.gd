extends Ability
class_name DominationAbility

func _init() -> void:
	ability_name = "Domination"
	ap_cost = 2
	adr_gain_on_use = 0.0

func execute(target: Character) -> void:
	var tier := get_current_tier()
	var status := DominationEffect.new()
	status.adr_gain_multiplier = 0.2
	if tier >= 2:
		status.bubble_ratio = 0.1
	if tier >= 4:
		status.lock_decay = true
		status.base_duration = 99
	apply_status(ability_owner, status)
	ability_owner.gain_adrenaline(8.0)
	last_damage_done = 0.0
