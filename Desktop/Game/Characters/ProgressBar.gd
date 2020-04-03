extends ProgressBar

var list
var waitingData = false

func _physics_process(delta):
	
	if  waitingData and  list.get_available_packet_count() > 0 :
		var data = list.get_packet()
		var a = data.get_string_from_utf8()
		value = int(a.split(":")[1])
		waitingData = false

func _on_Button_pressed():
	list = PacketPeerUDP.new()
	list.set_dest_address("127.0.0.1",1234)
	list.put_packet("2:None".to_ascii())
	list = PacketPeerUDP.new()
	list.listen(666)
	waitingData = true
	#value = int(life)
	
	pass # Replace with function body.
