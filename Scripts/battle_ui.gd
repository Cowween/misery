extends Control

signal attack
signal next_turn

var AP = 0
var target_hp = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_enemy_info()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$VBoxContainer/AP.text = "AP: %s" % AP

func update_p_health(hp:float, max_hp:float):
	print((hp/max_hp)*100)
	$PlayerBar.value = (hp/max_hp) * 100
	
func display_enemy_info(name:String, hp: float, max_hp: float) -> void:
	$EnemyBar.visible = true
	$EnemyName.visible = true
	$EnemyBar.value = (hp/max_hp) * 100
	$EnemyName.text = name
	
func hide_enemy_info() -> void:
	$EnemyBar.visible = false
	$EnemyName.visible = false

func _on_turn_pressed() -> void:
	emit_signal("next_turn")


func _on_attack_pressed() -> void:
	emit_signal("attack")
