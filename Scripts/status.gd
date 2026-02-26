extends ColorRect

@onready var stacks_count := $StacksCount
@onready var duration_text := $Duration

var no_of_stacks := 1
var s_name := ""

# Called when the node enters the scene tree for the first time.
func initialise(next_color : Color, is_player : bool, status_name: String, stacks: int, duration: int) -> void:
	color = next_color
	stacks_count.text = str(stacks)
	s_name = status_name
	duration_text.text = str(duration)
	if is_player:
		size_flags_horizontal = SIZE_EXPAND + SIZE_SHRINK_BEGIN
	else:
		size_flags_horizontal = SIZE_EXPAND + SIZE_SHRINK_END

func add_stacks() -> void:
	no_of_stacks += 1
	stacks_count.text = no_of_stacks
	
