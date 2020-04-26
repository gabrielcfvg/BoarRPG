extends Node
export var port:int = 1234
var thread
var thread2
var world = null
var boar = null
var boarEar = null
var AuthMenu



func _ready():
	OS.low_processor_usage_mode = true

###FUNÇÕES DE CONEXÃO###

func _connect_to_server(data):
	#Função que inicia todos os sockets e conexões com o server, 
	#permitindo o inicio do jogo
	
	#credenciais do usuário
	var ip= data[0]
	Global.nick = data[1]
	var pas = data[2]
	var code = data[3]
	
	#Conexão TCP com servidor do jogo
	boar = StreamPeerTCP.new()
	if boar.connect_to_host(ip,port) != 0:
		print("Connection error")
		AuthMenu.Message.text =  ("Connection error")
		return
	for i in range(1000):
		OS.delay_msec(1)
		if boar.get_status()==2:
			break
	if boar.get_status()!=2:
		print("Connection error")
		AuthMenu.Message.text =  ("Connection error")
		return
	AuthMenu.Message.text = ("Connected game to server")
	print("Connected game to server")
	
	#Criação do socket UDP
	boarEar = PacketPeerUDP.new()
	if boarEar.listen(666):
		AuthMenu.Message.Text = ("UDP listen error")
		print("UDP listen error")
		return
	
	if code == "0|":
		login(Global.nick,pas)
	elif code == "1|":
		register(Global.nick,pas)
	

func login(nick,pas):
	var buffer = StreamPeerBuffer.new()
	buffer = ("0:0|"+nick+"|"+pas+".").to_utf8()
	boar.put_data(buffer)
	thread = Thread.new()
	thread.start(self, "_listen_server_tcp",null)
	thread2 = Thread.new()
	thread2.start(self,"_listen_server_udp",null)
	return

func register(nick,pas):
	var buffer = StreamPeerBuffer.new()
	buffer = ("0:1|"+nick+"|"+pas+".").to_utf8()
	boar.put_data(buffer)
	thread = Thread.new()
	thread.start(self, "_listen_server_tcp",null)
	thread2 = Thread.new()
	thread2.start(self,"_listen_server_udp",null)
	return

func start_game():
	AuthMenu.get_node("Timer").start()

############################################################################



###FUNÇÕES DE ENVIO DE DADOS
func _send_position(pos):
	var data = StreamPeerBuffer.new()
	data = ("1:"+str(pos.x)+"/"+str(pos.y)+".").to_utf8()
	boar.put_data(data)
	pass

############################################################################

###FUNÇÕES DE REQUISIÇÃO###
func _request_map(index=null):
	var data = StreamPeerBuffer.new()
	if index==null:
		data = ("2:0.").to_utf8()
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

func _disconnect():
	var data = StreamPeerBuffer.new()
	data = "9".to_utf8()
	boar.put_data(data)
	boar.disconnect_from_host()
	pass # Replace with function body.

############################################################################

###FUNÇÕES DE RECEBIMENTO E PROCESSAMENTO DE RESPOSTAS###



func _listen_server_tcp(_trash):
	#Thread ouvindo streams do servidor, caso haja mais de 1 byte para ser coletado, 
	#o recebe e envia para a função de parsing
	var buffer = StreamPeerBuffer.new()
	while true:
		if(boar.get_status()!=2):
			print(boar.get_status())
			print("breaking listen")
			break
			
		var i = boar.get_available_bytes()
		if i<=0:
			continue
		print("recieved TCP data "+str(i)+" bytes")
		buffer = boar.get_string(i)
		call_deferred("parse_data",buffer,true)

func _listen_server_udp(_trash):
	#Thread ouvindo pacotes sem resosta do servidor, caso haja mais de 1 byte
	#para ser colatao, o recebe e envia para a função de parsing
	var buffer = PacketPeerStream.new()
	while true:
		var i = boarEar.get_available_packet_count()
		if i<=0:
			continue
		print("recieved UDP data" + str(i) + "bytes")
		buffer = boarEar.get_packet()
		call_deferred("parse_data",buffer.get_string_from_utf8(),false)




var raw_queue_udp = ""
var raw_queue_tcp = ""
var queue = []
func parse_data(raw,tcp):
	#Recebe pacotes brutos, remove caracteres nulos e o organiza para execução
	#Strings são enviadas para uma string maior temporaria, quando essa string
	#acaba com ponto(.) ela é adicionada a queue de execução e enviada
	#para execução
	if len(raw) == 0:
		return
	#print(raw)
	raw = raw.replace(" ","")
	if tcp:
		if raw[len(raw)-1] == ".":
			raw_queue_tcp+=raw
			queue.append(raw_queue_tcp)
			raw_queue_tcp = ""
			_execute_instruction()
		else:
			raw_queue_tcp+=raw
	else:
		if raw[len(raw)-1] == ".":
			raw_queue_udp+=raw
			queue.append(raw_queue_udp)
			raw_queue_udp = ""
			_execute_instruction()
		else:
			raw_queue_udp+=raw


func _execute_instruction():
	#Recebe uma instrução, retira caracteres de controle e baseado no indentificador
	#executa o código especifico de cada protocolo
	var instruction = queue[0].split(".")[0]
	var protocol = instruction.split(":")
	if(len(instruction)<100):
		print("Executing =="+instruction)
	
	if protocol[0] == "0":
		#login/registro
		var auth_data = protocol[1].split("|")
		var answer_code = auth_data[1]
		if auth_data[0]=="0":
			#login
			if answer_code=="0":
				AuthMenu.Message.text = ("Logged as "+Global.nick)
				print("Logged as "+Global.nick)
				call_deferred("start_game")
			elif answer_code=="1" :
				AuthMenu.Message.text =  ("Wrong password")
				print("Wrong password")
			elif answer_code=="2":
				AuthMenu.Message.text = ("No user with this nick") 
				print("No user with this nick") 
		elif auth_data[0] == "1":
			#registro
			print("register answer")
			if answer_code=="0":
				AuthMenu.Message.text = ("Registered as "+Global.nick)
				print("Registered as "+Global.nick)
			elif answer_code=="1":
				AuthMenu.Message.text = (Global.nick +" is not avaliable")
				print(Global.nick +" is not avaliable")
	elif protocol[0] == "1":
		#Posição dos outros jogadores
		var data = protocol[1].split("|")
		var pos = data[1].split("/")
		if world != null:
			world._update_player(data[0],pos)
	elif protocol[0]== "2":
		#download de mapa
		print("downloading map")
		var data = protocol[1].split("|")
		var chunk_name = data[0]
		var chunk_size = int(data[2]) 
		var player_pos = data[3].split("/")
		Global.player_position = Vector2(int(player_pos[0]),int(player_pos[1]))
		Global.chunk_size = chunk_size
		var chunk_index = data[1]#necessário converter a string para vetor2
		var tiles_array = []
		for i in range(4,4+chunk_size):
			var tile = data[i].split("/")
			tiles_array.append(tile)
		print("mapa size = "+str(len(tiles_array)))
		world._start_loading([chunk_size,tiles_array,[chunk_name,chunk_index]])
	elif protocol[0]=="666":
		#resposta de ping
		print("/////")
		print(protocol)
		print(OS.get_system_time_msecs())
		print("/////")
		var send_time = int(protocol[1])
		var now_time = OS.get_system_time_msecs()
		var el_time = now_time-send_time
		print("ELAPSED TIME: "+ str(el_time)+"ms")
		queue.remove(0)
	else:
		print('invalid package')
	queue.remove(0)






