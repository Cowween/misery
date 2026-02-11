extends Button

var signal_bus: Node
var abilityID:int


func _on_pressed() -> void:
	signal_bus.atk_pressed.emit(abilityID)
	print("pressed")
