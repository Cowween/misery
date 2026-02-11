extends Node
class_name BattleState

var main: Main # Reference to Main.gd
var state_machine: BattleStateMachine
var signal_bus: SignalBus

# 'msg' allows passing data between states (e.g. "attack_target": enemy)
func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass
