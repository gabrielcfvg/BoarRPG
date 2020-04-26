extends Node

var father
func _ready():
	father = get_node("..")

############Funções não thread-safe, chamadas de fora da thread principal############
func set_region_name(name):
	$CanvasLayer/Region.text = name

func preload_asset(id):
	match id:
		1:
			assets["1"] = preload("res://Scenario/Tiles/White.tscn")
		2:
			assets["2"] = preload("res://Scenario/Tiles/Black.tscn")
		3:
			assets["3"] = preload("res://Scenario/Tiles/Blue.tscn")
		4:
			assets["4"] = preload("res://Scenario/Tiles/Yellow.tscn")

func instance_tile(id,pos):
	var mapTile = assets[id].instance()
	father.add_child(mapTile)
	mapTile.position = mapTile.texture.get_size()*pos

func instance_player(_trash):
	var player = preload("res://Characters/Player.tscn")
	var p = player.instance()
	father.add_child(p)

#WORK IN PROGRESS
#func change_loading_text(text,progress):
#	get_node("../CanvasLayer/Panel/VBoxContainer/Label").text = text
#	get_node("../CanvasLayer/Panel/VBoxContainer/ProgressBar").value = progress
#	pass


func clean_bar():
	get_node("../CanvasLayer/Panel").visible = false

####################################################################################

func _gen_map(input):
	###gera um array bidimensional de dimensões size representando o mapa
	var size = input[0]
	var tiles = input[1]
	var name = input[2]
	var map = []
	var ss = sqrt(size)
	for x in range(ss):
		var line = []
		for y in range(ss):
			var t = tiles[(x*ss)+y][0]
			line.append(int(t))
		map.append(line)
	render_map(map)
	father.call_deferred("set_region_name",name[0]+"["+name[1]+"]")



var assets = {}
func render_map(mapArray):
	var load_list = []
	for x in len(mapArray):
		for y in len(mapArray[0]):
			if not mapArray[x][y] in load_list:
				load_list.append(mapArray[x][y])
	var total = len(load_list)
	var prog = 0
	for i in load_list:
		
		call_deferred("preload_asset",i)
		prog+=1
		call_deferred("change_loading_text","Preloading tiles",(total/prog)*100)


	total = len(mapArray)*len(mapArray[0])
	prog = 0
	for x in range(len(mapArray)):
		for y in range(len(mapArray[0])):
			call_deferred("instance_tile",str(mapArray[y][x]),Vector2(x,y))
			prog+=1
			#call_deferred("change_loading_text","Instancing tiles",(total/prog)*100)
	
	
	call_deferred("instance_player",null)
	#call_deferred("clean_bar")
