@abstract
extends Node
class_name Ability

@export var atk_multiplier := 1.0
@export var ap_cost := 1
@export var ability_name := ""
@export var ability_range : AbilityRange
@export var status_infliction: PackedScene
@export var uses_class_range := true
@export var fixed_max_range := 1
@export var fixed_min_range := 1
@export_enum("physical", "metaphorical") var damage_type := "physical"
@export_enum("", "str", "dex", "int", "arc") var scaling_stat := ""
@export_group("Momentum Tuning")
@export var tier_1_range_bonus := 1
@export var tier_2_range_bonus := 2
@export var tier_3_range_bonus := 3
@export var tier_4_range_bonus := 4
@export var tier_1_ap_discount := 1
@export var tier_2_ap_discount := 2
@export var tier_3_ap_discount := 2
@export var tier_4_ap_discount := 3
@export var tier_1_damage_bonus := 0.25
@export var tier_2_damage_bonus := 0.75
@export var tier_3_damage_bonus := 1.25
@export var tier_4_damage_bonus := 2.0
@export var tier_2_extra_hits := 1
@export var tier_3_extra_hits := 2
@export var tier_4_extra_hits := 3
@export var adr_gain_on_use := 5.0
@export var adr_gain_per_damage := 0.2

var ability_owner: Character
var base_max_range := 1
var base_min_range := 0
var last_damage_done := 0.0


@abstract func execute(target: Character) -> void

func set_walkable(walkable_cells: Array[Vector3]) -> void:
	ability_range.walkable_cells = walkable_cells

func set_ability_owner(owner: Character) -> void:
	ability_owner = owner
	ability_range.actor = owner
	if not uses_class_range:
		set_range(fixed_max_range, fixed_min_range)
	_apply_current_tier_to_range()

func inflict_status(target: Character, status_name: String, secondary: PackedScene = null, stacks:=0) -> void:
	for i in target.status_effects:
		if i.status_name == status_name:
			i.add_stack()
			return
	var new_status : Node
	if not secondary:
		new_status = status_infliction.instantiate()
	else:
		new_status = secondary.instantiate()
	print("Applying ", new_status.status_name, "to ", target.cname)
	if stacks != 0:
		new_status.stacks = stacks
	new_status.on_apply(target)
	target.add_child(new_status)
	target.status_update()

func apply_status(target: Character, status: StatusEffect, stacks := 0) -> void:
	if not target or not status:
		return
	for existing in target.status_effects:
		if existing.status_name == status.status_name:
			existing.add_stack(maxi(1, stacks))
			status.queue_free()
			target.status_update()
			return
	if stacks > 0:
		status.stacks = stacks
	status.on_apply(target)
	target.add_child(status)
	target.status_update()

func set_range(max_range: int, min_range: int) -> void:
	base_max_range = max_range
	base_min_range = min_range
	_apply_current_tier_to_range()

func prepare_for_use() -> void:
	_apply_current_tier_to_range()

func get_current_tier() -> int:
	if not ability_owner:
		return 0
	return ability_owner.get_adrenaline_tier()

func get_display_name() -> String:
	var tier := get_current_tier()
	if tier == 1:
		return ability_name + " I"
	if tier == 2:
		return ability_name + " II"
	if tier == 3:
		return ability_name + " III"
	if tier == 4:
		return ability_name + " IV"

	return ability_name

func get_ap_cost() -> int:
	var tier := get_current_tier()
	var discount := 0
	if tier == 1:
		discount = tier_1_ap_discount
	elif tier == 2:
		discount = tier_2_ap_discount
	elif tier == 3:
		discount = tier_3_ap_discount
	elif tier >= 4:
		discount = tier_4_ap_discount
	var discounted_cost := max(1, ap_cost - discount)
	if ability_owner and ability_owner.character_class:
		return ability_owner.character_class.get_modified_ap_cost(ability_owner, discounted_cost)
	return discounted_cost

func get_damage_multiplier() -> float:
	var tier := get_current_tier()
	if tier == 1:
		return atk_multiplier + tier_1_damage_bonus
	if tier == 2:
		return atk_multiplier + tier_2_damage_bonus
	if tier == 3:
		return atk_multiplier + tier_3_damage_bonus
	if tier >= 4:
		return atk_multiplier + tier_4_damage_bonus
	return atk_multiplier

func get_hit_count() -> int:
	var tier := get_current_tier()
	if tier == 2:
		return 1 + tier_2_extra_hits
	if tier == 3:
		return 1 + tier_3_extra_hits
	if tier >= 4:
		return 1 + tier_4_extra_hits
	return 1

func deal_damage(target: Character, damage_multiplier := -1.0) -> float:
	if not target or not is_instance_valid(target):
		return 0.0
	var total_damage := 0.0
	var active_multiplier := damage_multiplier
	if active_multiplier < 0.0:
		active_multiplier = get_damage_multiplier()
	for _hit in range(get_hit_count()):
		var damage := ability_owner.get_scaled_atk_val(scaling_stat) * active_multiplier
		if randf_range(0.0, 100.0) < ability_owner.crit_rate:
			damage *= 1.5
		total_damage += target.take_damage(damage, ability_owner, damage_type)
		if not is_instance_valid(target):
			break
	ability_owner.gain_adrenaline(adr_gain_on_use + total_damage * adr_gain_per_damage)
	last_damage_done = total_damage
	return total_damage

func _apply_current_tier_to_range() -> void:
	if not ability_range:
		return
	var tier := get_current_tier()
	var range_bonus := 0
	if tier == 1:
		range_bonus = tier_1_range_bonus
	elif tier == 2:
		range_bonus = tier_2_range_bonus
	elif tier == 3:
		range_bonus = tier_3_range_bonus
	elif tier >= 4:
		range_bonus = tier_4_range_bonus
	ability_range.max_range = base_max_range + range_bonus
	ability_range.min_range = base_min_range
