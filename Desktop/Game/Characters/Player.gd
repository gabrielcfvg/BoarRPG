extends Sprite

var offsetWorldPos
var map_size = 3600
func _ready():
	_update_position()
	offsetWorldPos = get_node("..").global_position

func _physics_process(delta):
	if Input.is_mouse_button_pressed(2):
		#abre menu de movimentação
		var menu = get_node("Control")
		var mouse = get_global_mouse_position()-offsetWorldPos
		menu.targetIndex = Vector2(int(mouse[0]/Global.CELL_SIZE),int(mouse[1]/Global.CELL_SIZE))
		menu.global_position = get_global_mouse_position()
		menu.visible = true
	
	#movimentação via WASD
	if can_walk:
		if Input.is_action_pressed("ui_up"):
			Global.player_position.y-=1
			_update_position()
		elif Input.is_action_pressed("ui_down"):
			Global.player_position.y+=1
			_update_position()
		elif Input.is_action_pressed("ui_left"):
			Global.player_position.x -=1
			_update_position()
		elif Input.is_action_pressed("ui_right"):
			Global.player_position.x +=1
			_update_position()

var can_walk:bool = true
func _on_walk_time_timeout():
	can_walk = true
	pass # Replace with function body.

func _update_position():
	#bloqueia a movimentação pelo próximo segundo
	can_walk = false
	$walk_time.start()
	var pos_index = Global.player_position
	#define a posição do jogador e envia para o servidor
	#print(Con.boar.get_status())
	var parent = get_node("..")
	if(pos_index.x>sqrt(Global.chunk_size)-1):
		print("right")
		parent.change_chunk(Vector2(1,0))
		Global.player_position = Vector2(0,pos_index.y)
		_update_position()
	elif pos_index.x<0:
		parent.change_chunk(Vector2(-1,0))
		print("left")
		Global.player_position = Vector2(59,pos_index.y)
		_update_position()
	elif(pos_index.y>sqrt(map_size)-1):
		parent.change_chunk(Vector2(0,1))
		print("down")
		Global.player_position = Vector2(pos_index.x,0)
		_update_position()
	elif(pos_index.y<0):
		print("up")
		parent.change_chunk(Vector2(0,-1))
		Global.player_position = Vector2(pos_index.x,59)
		_update_position()
	else:
		global_position = pos_index*Vector2(Global.CELL_SIZE,Global.CELL_SIZE) + Vector2(Global.CELL_SIZE/2,Global.CELL_SIZE/2)
		Con._send_position(pos_index)


