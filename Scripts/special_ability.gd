extends Node
class_name SpecialAbility

@export var ability_range: AbilityRange
@export var atk_multiplier := 1
@export var ap_cost := 1
@export var ability_name := ""
@export var adr_cost := 1
@export_enum("physical", "metaphorical") var damage_type := "metaphorical"
@export_enum("", "str", "dex", "int", "arc") var scaling_stat := ""
@export_group("Momentum Tuning")
@export var requires_awakened := true
@export var consume_all_adrenaline := true
@export var adr_gain_on_use := 0.0

var aim_required := false
var ability_owner: Character

	
func set_ability_owner(owner: Character) -> void:
	ability_owner = owner
	ability_range.actor = owner

func can_execute() -> bool:
	if not ability_owner:
		return false
	if requires_awakened and ability_owner.get_adrenaline_tier() < 2:
		return false
	return ability_owner.adrenaline >= adr_cost

func pay_cost() -> bool:
	if not can_execute():
		return false
	if consume_all_adrenaline:
		ability_owner.spend_all_adrenaline()
	else:
		ability_owner.adrenaline -= adr_cost
	if adr_gain_on_use > 0.0:
		ability_owner.gain_adrenaline(adr_gain_on_use)
	return true

func deal_damage(target: Character) -> float:
	if not target or not is_instance_valid(target):
		return 0.0
	var damage := ability_owner.get_scaled_atk_val(scaling_stat) * atk_multiplier
	if randf_range(0.0, 100.0) < ability_owner.crit_rate:
		damage *= 1.5
	return target.take_damage(damage, ability_owner, damage_type)

func execute(targets: Array[Character]) -> void:
	pass
