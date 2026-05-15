extends Ability
class_name NeuralSpikeAbility

func _init() -> void:
	ability_name = "Neural Spike"
	ap_cost = 2
	uses_class_range = false
	fixed_max_range = 4
	fixed_min_range = 1
	adr_gain_on_use = 5.0

func execute(target: Character) -> void:
	var tier := get_current_tier()
	if tier <= 1:
		target.gain_adrenaline(10.0)
	elif tier == 2:
		target.prevent_adr_decay_turns += 1
		target.action_points -= 1
	elif tier == 3:
		_push_to_next_tier(target, 3)
		target.prevent_adr_decay_turns += 1
		target.action_points -= 2
	else:
		var spike := NeuralSpikeEffect.new()
		spike.max_adr_turns = 3
		spike.base_duration = 3
		spike.stun_after = true
		apply_status(target, spike)
	ability_owner.gain_adrenaline(adr_gain_on_use)
	last_damage_done = 0.0

func _push_to_next_tier(target: Character, max_tier: int) -> void:
	var next_tier := min(max_tier, target.get_adrenaline_tier() + 1)
	match next_tier:
		1:
			target.adrenaline = max(target.adrenaline, target.tier_1_threshold)
		2:
			target.adrenaline = max(target.adrenaline, target.tier_2_threshold)
		3:
			target.adrenaline = max(target.adrenaline, target.tier_3_threshold)
