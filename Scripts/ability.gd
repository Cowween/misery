@abstract
extends Node
class_name Ability

@export var atk_multiplier := 1
@export var ap_cost := 1
@export var ability_name := ""
@export var ability_range : AbilityRange
@export var status_infliction: PackedScene

var ability_owner: Character

@abstract func execute(target: Character) -> void


func set_range(max_range: int, min_range: int) -> void:
	ability_range.max_range = max_range
	ability_range.min_range = min_range
