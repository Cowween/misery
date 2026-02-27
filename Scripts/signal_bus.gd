extends Node
class_name SignalBus

signal action_done
signal walk_finished
signal ap_update(value:int)
signal hp_update(value:float)
signal atk_pressed(atk_id: int)
signal special_pressed(toggle: bool, special_id: int)
signal turn_start
signal turn_end
signal status_update(target: Character, is_player: bool)
signal adr_update(value: float, max_value: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_battle_ui_next_turn() -> void:
	emit_signal("action_done")
