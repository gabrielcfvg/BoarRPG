extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var socket = PacketPeerUDP.new()
	socket.set_dest_address("127.0.0.1",1234)
	socket.put_packet("quit".to_ascii())
	print("Exiting application")    
	socket.get_packet()
	print(socket)
	
