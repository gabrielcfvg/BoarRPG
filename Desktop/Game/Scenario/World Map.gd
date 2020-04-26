extends Node2D
var WhiteTile = "res://Scenario/Tiles/WhiteTile.tscn"
var GreenTile = "res://Scenario/Tiles/GreenTile.tscn"
var BlueTile = "res://Scenario/Tiles/BlueTile.tscn"
var RedTile = "res://Scenario/Tiles/RedTile.tscn"


var character = preload("res://Characters/Enemy.tscn")
var players = []
const CELL_SIZE = 64

func _ready():
	if !Global.start:
		Con.world = self
		Con._request_map()
		Global.start = true
	else:
		print("req")
		Con.world = self
		Con._request_map(Global.chunk_position)

func change_chunk(side):
	#modifica o index do chunk atual e recarrega a cena
	Global.chunk_position+= side
	get_tree().reload_current_scene()
	

func _start_loading(map):
	$MapRender._gen_map(map)







func _update_player(name,pos):
	if !(name in players):
		players.append(name)
		add_player(name,pos)
	else:
		var pos_index = Vector2(int(pos[0]),int(pos[1]))
		get_node(name).global_position = pos_index*Vector2(CELL_SIZE,CELL_SIZE) + Vector2(CELL_SIZE/2,CELL_SIZE/2)

func add_player(name,pos):
	players.append(name)
	var np =character.instance()
	add_child(np)
	np.name = name
	np.get_node("Label").text = name
	#np.modulate = Color(randi()%255)
	var pos_index = Vector2(int(pos[0]),int(pos[1]))
	np.global_position = pos_index*Vector2(CELL_SIZE,CELL_SIZE) + Vector2(CELL_SIZE/2,CELL_SIZE/2)



func _on_Disco_pressed():
	Con._disconnect()
	pass # Replace with function body.


func _on_Ping_pressed():
	Con.test_ping()
	pass # Replace with function body.
