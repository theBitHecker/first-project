extends StaticBody2D

func set_doors(door_list: Array):
	$Up/Up.visible = door_list[0]
	$"Up/Off 1".disabled = door_list[0]
	$Right/Right.visible = door_list[1]
	$"Right/Off 1".disabled = door_list[1]
	$Down/Down.visible = door_list[2]
	$"Down/Off 1".disabled = door_list[2]
	$Left/Left.visible = door_list[3]
	$"Left/Off 1".disabled = door_list[3]
