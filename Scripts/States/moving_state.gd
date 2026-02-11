# misery/Scripts/States/moving_state.gd
extends BattleState

var attack_after_walk := false
var saved_target_pos := Vector3.ZERO

func enter(msg: Dictionary = {}) -> void:
	print("Moving state")
	attack_after_walk = msg.get("attack_after_walk", false)
	saved_target_pos = msg.get("target_pos", Vector3.ZERO)
	
	# Listen for the signal from Main's SignalBus or Main itself
	# Assuming SignalBus is a child of Main or globally accessible
	if not signal_bus.is_connected("walk_finished", _on_walk_finished):
		signal_bus.walk_finished.connect(_on_walk_finished)

func exit() -> void:
	# Disconnect to prevent double triggers
	if signal_bus.is_connected("walk_finished", _on_walk_finished):
		signal_bus.walk_finished.disconnect(_on_walk_finished)

func _on_walk_finished() -> void:
	if attack_after_walk:
		# Transition to Attack Mode, pre-selecting the target
		state_machine.change_state("AttackTargetingState", {"auto_target": saved_target_pos})
	else:
		# Just end the action
		state_machine.change_state("SelectionState")
