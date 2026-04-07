extends Button

@onready var ap_cost := $APCost

var signal_bus: Node
var abilityID:int

func set_ap(cost: int) -> void:
	ap_cost.text = str(cost)

func _on_pressed() -> void:
	signal_bus.atk_pressed.emit(abilityID)
	print("pressed")
