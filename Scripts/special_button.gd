extends Button

class_name SpecialButton
var signal_bus : SignalBus

var special_id:int


func _on_toggled(toggled_on: bool) -> void:
	signal_bus.emit_signal("special_pressed", toggled_on, special_id)
