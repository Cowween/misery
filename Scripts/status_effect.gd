extends Node
class_name StatusEffect

@export var duration := 1
@export var status_name := ""

# Called when the node enters the scene tree for the first time.
func on_apply(target: Character) -> void:
	pass
	
func on_remove(target: Character) -> void:
	pass
	
func on_turn_start(target: Character) -> void:
	pass
	
func on_turn_end(target: Character) -> void:
	pass
