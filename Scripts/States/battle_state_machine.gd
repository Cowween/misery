extends Node
class_name BattleStateMachine

@export var initial_state: BattleState

var current_state: BattleState
var states: Dictionary = {}
@export var signal_bus : SignalBus

func _ready() -> void:
	# Find the Main node (assuming StateMachine is a child of Main)
	var main_node = get_parent()
	
	for child in get_children():
		if child is BattleState:
			states[child.name.to_lower()] = child
			child.main = main_node
			child.signal_bus = signal_bus
			child.state_machine = self
	
	if initial_state:
		change_state(initial_state.name)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(state_name: String, msg: Dictionary = {}) -> void:
	var new_state = states.get(state_name.to_lower())
	if not new_state:
		printerr("State not found: " + state_name)
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter(msg)
