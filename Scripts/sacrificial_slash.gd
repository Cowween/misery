extends Ability

@export var victim_status : PackedScene
@export var sac_stacks := 1

func execute(target: Character) -> void:
	inflict_status(ability_owner, "Sacrifice", null, sac_stacks)
	inflict_status(target, "Sacrificial Lamb", victim_status, sac_stacks)
	target.hp -= ability_owner.get_atk_val() * atk_multiplier
	
