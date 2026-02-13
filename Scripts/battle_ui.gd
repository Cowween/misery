extends Control

signal attack
signal next_turn

@onready var ap_text := $PlayerInfo/AP
@onready var player_bar := $PlayerInfo/Health/PlayerBar
@onready var atk_btn := $PlayerInfo/FunctionalButtons/Attack
@onready var turn_btn := $PlayerInfo/FunctionalButtons/Turn
@onready var enemy_name := $EnemyInfo/EnemyName
@onready var enemy_bar := $EnemyInfo/EnemyBar
@onready var esoterica := $PlayerInfo/Esoterica
@onready var adrenaline_bar := $PlayerInfo/ADR

@export var signal_bus: SignalBus


var AP := 0
var target_hp := 0
var special_buttons := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	special_buttons = esoterica.get_children()
	hide_enemy_info()
	for i in special_buttons:
		i.signal_bus = signal_bus
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func update_p_health(hp:float, max_hp:float):
	print((hp/max_hp)*100)
	player_bar.value = (hp/max_hp) * 100
	
func display_enemy_info(name:String, hp: float, max_hp: float) -> void:
	enemy_bar.visible = true
	enemy_name.visible = true
	enemy_bar.value = (hp/max_hp) * 100
	enemy_name.text = name
	
func update_ap(value:int) -> void:
	ap_text.text = "AP: %s" % value
	
func hide_enemy_info() -> void:
	enemy_bar.visible = false
	enemy_name.visible = false

func update_specials(specials_list: Array[SpecialAbility]) -> void:
	for i in specials_list.size():
		special_buttons[i].special_id = i

func update_adrenaline(adrenaline: int, max_adr: int) -> void:
	adrenaline_bar.value = adrenaline
	adrenaline_bar.max_value = max_adr

func _on_turn_pressed() -> void:
	emit_signal("next_turn")


func _on_attack_pressed() -> void:
	emit_signal("attack")


func _on_signal_bus_ap_update(value: int) -> void:
	update_ap(value)
