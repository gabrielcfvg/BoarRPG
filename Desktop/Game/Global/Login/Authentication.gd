extends CanvasLayer

var Message


func _ready():
	Message = $VBoxContainer/Message
	var save = File.new()
	if save.file_exists("user://ip.txt"):
		save.open("user://ip.txt", File.READ)
		$VBoxContainer/IP/IpInput.text = save.get_as_text()
		save.close()
	if save.file_exists("user://credentials.dat"):
		save.open_encrypted_with_pass("user://credentials.dat",save.READ,OS.get_unique_id())
		print(save)
		var creds = save.get_as_text().split("|")
		print(creds)
		if len(creds)<2:
			return
		$VBoxContainer/Nick/NickInput.text = creds[0]
		$VBoxContainer/Pass/PassInput.text = creds[1]

func _on_Login_pressed():
	var ip = get_node("VBoxContainer/IP/IpInput").text
	var nick = get_node("VBoxContainer/Nick/NickInput").text
	var password = get_node("VBoxContainer/Pass/PassInput").text
	Con.AuthMenu = self
	if $VBoxContainer/HBoxContainer/RememberMe.pressed:
		var save = File.new()
		save.open("user://ip.txt", File.WRITE)
		save.store_string($VBoxContainer/IP/IpInput.text)
		save.close()
		save.open_encrypted_with_pass("user://credentials.dat",save.WRITE,OS.get_unique_id())
		save.store_string($VBoxContainer/Nick/NickInput.text+"|"+$VBoxContainer/Pass/PassInput.text)
		save.close()
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

