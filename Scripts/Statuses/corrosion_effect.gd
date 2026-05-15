extends StatusEffect
class_name CorrosionEffect

@export var damage_per_turn := 8.0
@export var adr_drain_per_turn := 0.0

func _init() -> void:
	status_name = "Corrosion"
	base_duration = 4
	texture = Color(0.35, 0.9, 0.35, 1.0)

func on_apply(target: Character) -> void:
	victim = target
	target.status_effects.append(self)

func on_turn_start() -> void:
	if not victim:
		return
	victim.take_damage(damage_per_turn * stacks, null, "metaphorical", false)
	if adr_drain_per_turn > 0.0:
		victim.adrenaline -= adr_drain_per_turn * stacks

func on_turn_end() -> void:
	_duration -= 1
