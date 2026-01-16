extends WeaponData
class_name PencilData

@export_group("Pencil Attack")
@export var attack_knockback: float
@export var attack_shape: Shape2D
@export var attack_offset: Vector2
@export_group("Pencil Ability")
@export var dash_speed: float
@export var ability_shape: Shape2D
@export var ability_offset: Vector2
var hit_list: Array[Node2D]


func execute_attack(player: CharacterBody2D):
	hit_list = []
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", attack_shape)
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("position", attack_offset)
	player.weapon_state = player.weapon_states.ATTACK
	
func execute_ability(player: CharacterBody2D):
	player.weapon_state = player.weapon_states.ABILITY_BEGIN
	player.mana_recharge = 0
	player.velocity -= 0.1*dash_speed*player.attack_control_vector
	hit_list = []
	await player.get_tree().create_timer(0.5).timeout
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", ability_shape)
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("position", ability_offset)
	player.velocity += 1.1*dash_speed*player.attack_control_vector
	player.mana_recharge = 10
	player.weapon_state = player.weapon_states.ABILITY

func weapon_state_change(player: CharacterBody2D):
	if (player.cooldown <= 0.5) and player.weapon_state == player.weapon_states.ABILITY:
		player.weapon_state = player.weapon_states.ABILITY_END
	if player.cooldown <= 0.25 and player.weapon_state == player.weapon_states.ABILITY_END:
		player.weapon_state = player.weapon_states.IDLE
		player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", null)
	if player.cooldown <= 0.01 and player.weapon_state == player.weapon_states.ATTACK:
		player.weapon_state = player.weapon_states.IDLE
		player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", null)
func weapon_collision(player: CharacterBody2D, bodies: Array[Node2D]):
	for body in bodies:
		if player.weapon_state == player.weapon_states.ATTACK:
			if body.is_in_group("Enemy"):
				if not(body in hit_list):
					body.velocity += player.attack_control_vector * attack_knockback
					hit_list.append(body)
		if player.weapon_state == player.weapon_states.ABILITY:
			if body.is_in_group("Enemy"):
				if not(body in hit_list):
					body.velocity += player.velocity
					if len(hit_list) >= 3:
						player.velocity = player.velocity.bounce((player.global_position - body.global_position).normalized())
					else:
						hit_list.append(body)
	
