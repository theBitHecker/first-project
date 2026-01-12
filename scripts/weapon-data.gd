extends Resource
class_name WeaponData

@export_group("Visuals")
@export var name: String
@export var animations: Dictionary = {
	"idle": null
}

@export_group("Stats")
@export var attack_mana_cost: int
@export var ability_mana_cost: int
@export var attack_cooldown: float
@export var ability_cooldown: float


func execute_attack(_player: CharacterBody2D):
	pass

func execute_ability(_player: CharacterBody2D):
	pass

func weapon_state_change(_player: CharacterBody2D):
	pass

func weapon_collision(_player: CharacterBody2D, _bodies: Array[Node2D]):
	pass
	
	
	
