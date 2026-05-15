extends StatusEffect
class_name NeuralSpikeEffect

@export var max_adr_turns := 0
@export var stun_after := false
var _turns := 0

func _init() -> void:
	status_name = "Neural Spike"
	base_duration = 1
	texture = Color(0.2, 0.9, 1.0, 1.0)

func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)
	_turns = max_adr_turns
	if max_adr_turns > 0:
		target.ap_cost_add -= 1

func on_turn_start() -> void:
	if victim and _turns > 0:
		victim.adrenaline = victim.max_adr
		_turns -= 1

func on_remove() -> void:
	if victim and max_adr_turns > 0:
		victim.ap_cost_add += 1
		if stun_after:
			victim.adrenaline = 0
			victim.action_points = 0
	super()

func on_turn_end() -> void:
	_duration -= 1
