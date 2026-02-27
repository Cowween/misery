extends Control

signal attack
signal next_turn
const status_icon := preload("uid://bphm2w3qsdq7a")

@onready var ap_text := $PlayerInfo/AP
@onready var player_bar := $PlayerInfo/Health/PlayerBar
@onready var atk_btn := $PlayerInfo/FunctionalButtons/Attack
@onready var turn_btn := $PlayerInfo/FunctionalButtons/Turn
@onready var enemy_name := $EnemyInfo/EnemyName
@onready var enemy_bar := $EnemyInfo/EnemyBar
@onready var esoterica := $PlayerInfo/Esoterica
@onready var adrenaline_bar := $PlayerInfo/ADR
@onready var player_statuses := $PlayerStatuses
@onready var enemy_statuses := $EnemyStatuses


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
	
func display_enemy_info(target: Character) -> void:
	enemy_bar.visible = true
	enemy_name.visible = true
	enemy_statuses.visible = true
	#print(target.hp/target.max_hp)
	enemy_bar.value = (target.hp/target.max_hp) * 100
	enemy_name.text = target.cname
	update_status_bar(target, false)
	
func update_ap(value:int) -> void:
	ap_text.text = "AP: %s" % value
	
func hide_enemy_info() -> void:
	enemy_bar.visible = false
	enemy_name.visible = false
	enemy_statuses.visible = false

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
	
func update_status_bar(target: Character, is_player: bool) -> void:
	var working_status_bar := enemy_statuses
	if is_player:
		working_status_bar = player_statuses
	for i in working_status_bar.get_children():
		i.queue_free()
	print(target.status_effects)
	for i in target.status_effects:
		var new_status := status_icon.instantiate()
		
		working_status_bar.add_child(new_status)
		new_status.initialise(i.texture, is_player, i.status_name, i.stacks, i._duration)
		
		


func _on_signal_bus_status_update(target: Character, is_player: bool) -> void:
	update_status_bar(target, is_player)


func _on_signal_bus_adr_update(value: float, max_value: float) -> void:
	update_adrenaline(value, max_value)
