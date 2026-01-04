extends WeaponData
class_name PencilData

@export_group("Pencil Ability")
@export var dash_speed: float # From your player script 
@export var ability_shape: Shape2D
@export var ability_offset: Vector2


func execute_attack(_player: CharacterBody2D):
	pass
	# code actual stab

func execute_ability(player: CharacterBody2D):
	player.weapon_state = player.weapon_states.ABILITY_BEGIN
	player.mana_recharge = 0
	player.velocity -= 0.1*dash_speed*player.attack_control_vector
	await player.get_tree().create_timer(0.5).timeout
	player.velocity += 1.1*dash_speed*player.attack_control_vector
	player.mana_recharge = 10
	player.weapon_state = player.weapon_states.ABILITY
