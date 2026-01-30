@abstract
extends Node
class_name Ability

@export var atk_multiplier := 1
@export var ap_cost := 1
@export var ability_name := ""

var ability_owner: Character

@abstract func execute(target: Character) -> void
