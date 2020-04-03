extends Node
export var port:int = 1234
var thread
var world
var boar = null
var AuthMenu


var nick

func _connect_to_server(data):
	var ip= data[0]
	nick = data[1]
	var pas = data[2]
	var login = data[3]
	boar = StreamPeerTCP.new()
	if boar.connect_to_host(ip,port) != 0:
		print("Connection error")
		return
	for i in range(1000):
		OS.delay_msec(1)
		if boar.get_status()==2:
			break
	if boar.get_status()!=2:
		print("Connection error")
		AuthMenu.Message.text =  ("Connection error")
		return
	#print(boar.get_status())
	print("connected to server")
	if login == "0|":
		login(nick,pas)
	elif login == "1|":
		register(nick,pas)
	

func login(nick,pas):
	var buffer = StreamPeerBuffer.new()
	buffer = ("0:0|"+nick+"|"+pas+".").to_utf8()
	boar.put_data(buffer)
	thread = Thread.new()
	thread.start(self, "_listen_server",null)
	return

func register(nick,pas):
	var buffer = StreamPeerBuffer.new()
	buffer = ("0:1|"+nick+"|"+pas+".").to_utf8()
	boar.put_data(buffer)
	thread = Thread.new()
	thread.start(self, "_listen_server",null)
	return


func _send_position(pos):
	var data = StreamPeerBuffer.new()
	data = ("1:"+str(pos.x)+"/"+str(pos.y)+".").to_utf8()
	boar.put_data(data)
	print("data sent")
	pass
	
func _request_map(index=null):
	var data = StreamPeerBuffer.new()
	if index==null:
		data = ("2:0").to_utf8()
		boar.put_data(data)
	else:
		data = ("2:1|"+str(index.x)+"/"+str(index.y)+".").to_utf8()
		boar.put_data(data)
	pass


func test_ping():
	var data = StreamPeerBuffer.new()
	data = ("666:"+str(OS.get_system_time_msecs())).to_utf8()
	boar.put_data(data)
	pass





func _listen_server(_trash):
	var buffer = StreamPeerBuffer.new()
	while true:
		var i = boar.get_available_bytes()
		if i==0:
			continue
		print("recieved data")
		buffer = boar.get_string(i)
		call_deferred("parse_data",buffer)
		


var downloading_map = false
var map_data

var raw_queue = ""
var queue = []
func parse_data(raw):
	raw = raw.replace(" ","")
	if raw[len(raw)-1] == ".":
		raw_queue+=raw
		queue.append(raw_queue)
		raw_queue = ""
		_execute_instruction()
	else:
		raw_queue+=raw


func _execute_instruction():
	var instruction = queue[0].split(".")[0]
	if(len(instruction)<100):
		print("Executing =="+instruction)
	var protocol = instruction.split(":")
	if protocol[0] == "1":
		#posição
		var data = protocol[1].split("|")
		var pos = data[1].split("/")
		get_node("..")._update_player(data[0],pos)
		queue.remove(0)
	elif protocol[0]== "2":
		downloading_map = true
		print("downloading map")
		#mapa
		var data = protocol[1].split("|")
		var chunk_name = data[0]
		var chunk_size = int(data[2]) 
		var chunk_index = data[1]#necessário converter a string para vetor2
		var tiles_array = []
		for i in range(3,3+chunk_size):
			var tile = data[i].split("/")
			tiles_array.append(tile)
		print("mapa size = "+str(len(tiles_array)))
		world._gen_map(chunk_size,tiles_array)
		queue.remove(0)
	elif protocol[0]=="666":
		#ping
		print("/////")
		print(protocol)
		print(OS.get_system_time_msecs())
		print("/////")
		var send_time = int(protocol[1])
		var now_time = OS.get_system_time_msecs()
		var el_time = now_time-send_time
		print("ELAPSED TIME: "+ str(el_time)+"ms")
		queue.remove(0)
	elif protocol[0] == "0":
		#login/registro
		var auth_data = protocol[1].split("|")
		var answer_code = auth_data[1]
		if auth_data[0]=="0":
			if answer_code=="0":
				AuthMenu.Message.text = ("Logged as "+nick)
				print("Logged as "+nick)
				call_deferred("start_game")
				queue.remove(0)
			elif answer_code=="1" :
				AuthMenu.Message.text =  ("Wrong password")
				print("Wrong password")
				queue.remove(0)
				return
			elif answer_code=="2":
				AuthMenu.Message.text = ("No user with this nick") 
				print("No user with this nick") 
				queue.remove(0)
				return
			queue.remove(0)
		elif auth_data[0] == "1":
			print("register answer")
			if answer_code=="0":
				AuthMenu.Message.text = ("Registered as "+nick)
				print("Registered as "+nick)
			elif answer_code=="1":
				AuthMenu.Message.text = (nick +" is not avaliable")
				print(nick +" is not avaliable")
			queue.remove(0)
	else:
		print('invalid package')




func start_game():
	AuthMenu.get_node("Timer").start()

func _disconnect():
	print("this rund")
	var data = StreamPeerBuffer.new()
	data = "9".to_utf8()
	boar.put_data(data)
	boar.disconnect_from_host()
	pass # Replace with function body.



