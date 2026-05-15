extends Resource
class_name CharacterClass

@export var display_name := "Character Class"
@export var level := 1

@export_group("Core Stats")
@export var max_hp := 100.0
@export var ap_per_turn := 5
@export var min_atk := 8.0
@export var max_atk := 12.0
@export var atk_range := 1
@export var def := 5.0
@export var res := 1.0
@export var crit_rate := 5.0
@export var spd := 10.0

@export_group("Scaling Stats")
@export var str_stat := 1.0
@export var dex_stat := 1.0
@export var int_stat := 1.0
@export var arc_stat := 1.0

@export_group("Adrenaline")
@export var initial_adr := 0.0
@export var max_adr := 500.0
@export var adr_decay_per_turn := 25.0
@export var tier_1_threshold := 60.0
@export var tier_2_threshold := 170.0
@export var tier_3_threshold := 320.0
@export var tier_4_threshold := 450.0

@export_group("Loadout")
@export var attack_ability_scenes: Array[PackedScene] = []
@export var special_ability_scenes: Array[PackedScene] = []

func apply_to_character(character: Character) -> void:
	character.hp = max_hp
	character.adrenaline = initial_adr

func get_adrenaline_tier(adrenaline: float) -> int:
	if adrenaline >= tier_4_threshold:
		return 4
	if adrenaline >= tier_3_threshold:
		return 3
	if adrenaline >= tier_2_threshold:
		return 2
	if adrenaline >= tier_1_threshold:
		return 1
	return 0

func roll_attack_value(_attacker: Character) -> float:
	return randf_range(min_atk, max_atk)

func get_attack_scale(_attacker: Character, scaling_stat: String) -> float:
	match scaling_stat:
		"str":
			return str_stat
		"dex":
			return dex_stat
		"int":
			return int_stat
		"arc":
			return arc_stat
		_:
			return 1.0

func get_modified_ap_cost(character: Character, base_cost: int) -> int:
	return max(0, base_cost + character.ap_cost_add)

func on_turn_start(_character: Character) -> void:
	pass

func on_turn_end(character: Character) -> void:
	if character.prevent_adr_decay_turns > 0:
		character.prevent_adr_decay_turns -= 1
		return
	if character.adr_decay_locked:
		return
	character.adrenaline -= adr_decay_per_turn

func on_tier_changed(_character: Character, _old_tier: int, _new_tier: int) -> void:
	pass

func on_damage_taken(_character: Character, _source: Character, _final_damage: float, _damage_type: String) -> void:
	pass

func on_attack_executed(_character: Character, _ability: Ability, _target: Character, _damage_done: float) -> void:
	pass
