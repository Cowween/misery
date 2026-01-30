@abstract
extends Node
class_name AbilityRange

@export var grid: Resource = preload("res://Resources/Grid.tres")
@export var max_range := 1
@export var min_range := 0

var actor: Character

@abstract func get_tiles_in_range() -> Array[Vector3]
	
