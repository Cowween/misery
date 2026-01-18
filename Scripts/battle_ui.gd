extends Control

signal attack
signal next_turn

var HP = 0 
var HP_max = 1
var AP = 0
var target_hp = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$VBoxContainer/AP.text = "AP: %s" % AP
	$PlayerBar.value = (HP/HP_max) * 100


func _on_turn_pressed() -> void:
	emit_signal("next_turn")
