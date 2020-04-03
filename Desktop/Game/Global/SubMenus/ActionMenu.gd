extends Node2D

var targetIndex
var PlayerIndex


func _on_Move_pressed():
	print("moved")
	print(targetIndex)
	get_node("..").pos_index = targetIndex
	get_node("..")._update_position()
	visible = false
	
	pass # Replace with function body.
