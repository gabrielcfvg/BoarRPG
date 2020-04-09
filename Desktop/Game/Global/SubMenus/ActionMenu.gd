extends Node2D

var targetIndex
var PlayerIndex


func _on_Move_pressed():
	print("moved")
	print(targetIndex)
	Global.player_position = targetIndex
	get_node("..")._update_position()
	visible = false
	
	pass # Replace with function body.
