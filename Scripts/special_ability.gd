extends Node
class_name SpecialAbility

@export var ability_range: AbilityRange
@export var atk_multiplier := 1
@export var ap_cost := 1
@export var ability_name := ""
@export var adr_cost := 1

var aim_required := false
var ability_owner: Character

	
func set_ability_owner(owner: Character) -> void:
	ability_owner = owner
	ability_range.actor = owner


func execute(targets: Array[Character]) -> void:
	pass
