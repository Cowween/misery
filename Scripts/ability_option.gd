extends Button

var SignalBus: Node
var abilityID:int


func _on_pressed() -> void:
	SignalBus.atk_pressed.emit(abilityID)
