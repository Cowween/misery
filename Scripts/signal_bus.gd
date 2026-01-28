extends Node

signal action_done
signal walk_finished
signal ap_update(value:int)
signal hp_update(value:int)
signal atk_pressed(atk_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_battle_ui_next_turn() -> void:
	emit_signal("action_done")
