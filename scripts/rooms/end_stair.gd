extends StaticBody2D

var enemy = preload("res://scenes/enemies/hw-spooder.tscn")
var end = false
func set_doors(door_list: Array, param_room_position):
	$Up/Up.visible = door_list[0]
	$"Up/Off 1".disabled = door_list[0]
	$Right/Right.visible = door_list[1]
	$"Right/Off 1".disabled = door_list[1]
	$Down/Down.visible = door_list[2]
	$"Down/Off 1".disabled = door_list[2]
	$Left/Left.visible = door_list[3]
	$"Left/Off 1".disabled = door_list[3]
	var room_position = param_room_position
	enemy = enemy.instantiate()
	enemy.position = position
	
	



func _on_body_touch_end(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_parent().end_level(self)
		
