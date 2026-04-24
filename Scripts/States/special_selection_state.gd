extends BattleState

var special : SpecialAbility
var s_range : Array[Vector3]
# Called when the node enters the scene tree for the first time.
func enter(msg: Dictionary = {}) -> void:
	print("Entering Special Selection Mode")
	special = msg.get("special")
	if not special or not special.can_execute():
		state_machine.change_state("SelectionState")
		return
	s_range = special.ability_range.get_tiles_in_range()
	main.overlay_draw(s_range, 1)

	if not signal_bus.is_connected("special_pressed", _on_special_pressed):
		signal_bus.special_pressed.connect(_on_special_pressed)
		

func exit() -> void:
	if signal_bus.is_connected("special_pressed", _on_special_pressed):
		signal_bus.special_pressed.disconnect(_on_special_pressed)
	main.deselect_unit_for_movement()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var cursor_pos := main.cursor_pos
		var targeted : Array[Character] = []
		if cursor_pos in s_range:
			var seen_targets := {}
			for i in s_range:
				var target := main.get_character_at(i)
				if target and not seen_targets.has(target):
					seen_targets[target] = true
					targeted.append(target)
			print(targeted)
			special.execute(targeted)
			main.battle_ui.update_adrenaline(main.current.adrenaline, main.current.max_adr)
			main.battle_ui.update_specials(main.current.special_abilities)
		state_machine.change_state("SelectionState")
		
	

func update(_delta: float) -> void:
	if special.aim_required:
		main.character_aiming(true)
		s_range = special.ability_range.get_tiles_in_range()
		main.overlay_draw(s_range, 1)
	
func _on_special_pressed(toggle:bool, special_id:int):
	if not toggle:
		state_machine.change_state("SelectionState")
