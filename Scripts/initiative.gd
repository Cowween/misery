extends Node

var queue = []
var queue_in_action = []
var current

# Called when the node enters the scene tree for the first time.
'''func _ready() -> void:
	queue = get_tree().get_nodes_in_group("Characters")
	queue.sort_custom(sort_queue)
	queue_in_action = queue.duplicate()
	current = queue_in_action.pop_front()
	current.moving = true
	get_parent().occupied_tiles[current] = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
	

func sort_queue(a, b):
	if a.initiative > b.initiative:
		return true
	else:
		return false


func _on_signal_bus_action_done() -> void:
	if queue_in_action.size() == 0:
		queue_in_action = queue.duplicate()

	current.moving = false
	var tile = Vector3i(current.location.x, 1, current.location.z)
	get_parent().occupied_tiles[current] = tile
	current = queue_in_action.pop_front()
	current.moving = true
	get_parent().occupied_tiles[current] = null'''
