extends Node
class_name StatusEffect

@export var base_duration := 1 
@export var status_name := ""
@export var stacks := 1
@export var texture : Color

var victim : Character
var _duration : int :  set = set_duration

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_duration = base_duration

func set_duration(value: int) -> void:
	_duration = value
	if _duration <= 0:
		on_remove()

func add_stack() -> void:
	_duration = base_duration
	stacks += 1

func on_apply(target: Character) -> void:
	pass
	
func on_remove() -> void:
	pass
	
func on_turn_start() -> void:
	pass
	
func on_turn_end() -> void:
	pass
