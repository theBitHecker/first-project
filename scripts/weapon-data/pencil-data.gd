extends WeaponData
class_name PencilData

@export_group("Pencil Ability")
@export var dash_speed: float
@export var ability_shape: Shape2D
@export var ability_offset: Vector2


func execute_attack(player: CharacterBody2D):
	player.weapon_state = player.weapon_states.ATTACK
	# code actual stab

func execute_ability(player: CharacterBody2D):
	player.weapon_state = player.weapon_states.ABILITY_BEGIN
	player.mana_recharge = 0
	player.velocity -= 0.1*dash_speed*player.attack_control_vector
	await player.get_tree().create_timer(0.5).timeout
	player.velocity += 1.1*dash_speed*player.attack_control_vector
	player.mana_recharge = 10
	player.weapon_state = player.weapon_states.ABILITY

func weapon_state_change(player: CharacterBody2D):
	if (player.cooldown <= 0.5) and player.weapon_state == player.weapon_states.ABILITY:
		player.weapon_state = player.weapon_states.ABILITY_END
	if player.cooldown <= 0.25 and player.weapon_state == player.weapon_states.ABILITY_END:
		player.weapon_state = player.weapon_states.IDLE
	if player.cooldown <= 0.01 and player.weapon_state == player.weapon_states.ATTACK:
		player.weapon_state = player.weapon_states.IDLE

func on_weapon_hit(player: CharacterBody2D, body: Node2D):
	if player.weapon_state == player.weapon_states.ATTACK:
		if body.is_in_group("Enemy"):
			pass
	if player.weapon_state == player.weapon_states.ABILITY:
		if body.is_in_group("Enemy"):
			pass
