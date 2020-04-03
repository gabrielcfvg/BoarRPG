extends CanvasLayer

var Message


func _ready():
	Message = get_node("VBoxContainer/Message")

func _on_Login_pressed():
	var ip = get_node("VBoxContainer/IP/IpInput").text
	var nick = get_node("VBoxContainer/Nick/NickInput").text
	var password = get_node("VBoxContainer/Pass/PassInput").text
	Con.AuthMenu = self
	var socketThread = Thread.new()
	socketThread.start(Con, "_connect_to_server",[ip,nick,password,"0|"])
	socketThread.wait_to_finish()
	
	pass # Replace with function body.


func _on_Register_pressed():
	var ip = get_node("VBoxContainer/IP/IpInput").text
	var nick = get_node("VBoxContainer/Nick/NickInput").text
	var password = get_node("VBoxContainer/Pass/PassInput").text
	Con.AuthMenu = self
	var socketThread = Thread.new()
	socketThread.start(Con, "_connect_to_server",[ip,nick,password,"1|"])
	socketThread.wait_to_finish()
	pass # Replace with function body.


func _on_Timer_timeout():
	get_tree().change_scene("res://Scenario/World Map.tscn")
	pass # Replace with function body.
