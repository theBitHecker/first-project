extends StaticBody2D

func set_doors(door_list: Array):
	$Up/Up.visible = not door_list[0]
	$"Up/Off 1".disabled = not door_list[0]
	$Right/Right.visible = not door_list[1]
	$"Right/Off 1".disabled = not door_list[1]
	$Down/Down.visible = not door_list[2]
	$"Down/Off 1".disabled = not door_list[2]
	$Left/Left.visible = not door_list[3]
	$"Left/Off 1".disabled = not door_list[3]
