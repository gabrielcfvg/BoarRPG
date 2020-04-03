extends Node2D
var WhiteTile = "res://Scenario/Tiles/WhiteTile.tscn"
var GreenTile = "res://Scenario/Tiles/GreenTile.tscn"
var BlueTile = "res://Scenario/Tiles/BlueTile.tscn"
var RedTile = "res://Scenario/Tiles/RedTile.tscn"

var character = preload("res://Characters/Enemy.tscn")
var players = []
const CELL_SIZE = 256


func _ready():
	Con.world = self
	Con._request_map()

func _gen_map(size,tiles):
	###gera um array bidimensional de dimensões size representando o mapa
	var map = []
	var ss = sqrt(size)
	for x in range(ss):
		var line = []
		for y in range(ss):
			var t = tiles[(x*ss)+y][1]
			line.append(int(t))
		map.append(line)
	render_map(map)



var assets = {}
func render_map(mapArray):
	var load_list = []
	for x in len(mapArray):
		for y in len(mapArray[0]):
			if not mapArray[x][y] in load_list:
				load_list.append(mapArray[x][y])
				match mapArray[x][y]:
					1:
						assets["1"]=preload("res://Scenario/Tiles/WhiteTile.tscn")
					2:
						assets["2"] = preload("res://Scenario/Tiles/GreenTile.tscn")
					3:
						assets["3"] = preload("res://Scenario/Tiles/BlueTile.tscn")
					4:
						assets["4"] = preload("res://Scenario/Tiles/RedTile.tscn")
	
	
	
	for x in range(len(mapArray)):
		for y in range(len(mapArray[0])):
			var mapTile = assets[str(mapArray[y][x])].instance()
			add_child(mapTile)
			mapTile.position = mapTile.texture.get_size()*Vector2(x,y)





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
	np.modulate = Color(randi()%255)
	var pos_index = Vector2(int(pos[0]),int(pos[1]))
	np.global_position = pos_index*Vector2(CELL_SIZE,CELL_SIZE) + Vector2(CELL_SIZE/2,CELL_SIZE/2)


func _on_Disco_pressed():
	Con._disconnect()
	pass # Replace with function body.


func _on_Ping_pressed():
	Con.test_ping()
	pass # Replace with function body.
