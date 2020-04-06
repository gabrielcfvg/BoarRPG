extends CanvasLayer


func _physics_process(delta):
	if Input.is_action_just_released("esc"):
		if($Itens.visible):
			$Itens.visible = false
		else:
			$Itens.visible = true
		pass




func _on_Disconnect_pressed():
	Con._disconnect()
	get_tree().change_scene("res://Global/Login/Login.tscn")
	Global.start = false
