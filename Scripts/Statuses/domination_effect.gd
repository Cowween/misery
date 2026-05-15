extends StatusEffect
class_name DominationEffect

@export var adr_gain_multiplier := 0.2
@export var bubble_ratio := 0.0
@export var lock_decay := false
var bubble_hp := 0.0

func _init() -> void:
	status_name = "Domination"
	base_duration = 2
	texture = Color(1.0, 0.85, 0.2, 1.0)

func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)
	if bubble_ratio > 0.0:
		bubble_hp = target.max_hp * bubble_ratio
	if lock_decay:
		target.adr_decay_locked = true

func on_remove() -> void:
	if victim and lock_decay:
		victim.adr_decay_locked = false
	super()

func on_turn_end() -> void:
	_duration -= 1
