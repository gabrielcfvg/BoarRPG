extends Sprite

var offsetWorldPos
const CELL_SIZE =256
var pos_index = Vector2(1,1)

func _ready():
	offsetWorldPos = get_node("..").global_position

func _physics_process(delta):
	if Input.is_mouse_button_pressed(2):
		#abre menu de movimentação
		var menu = get_node("Control")
		var mouse = get_global_mouse_position()-offsetWorldPos
		menu.targetIndex = Vector2(int(mouse[0]/256),int(mouse[1]/256))
		menu.global_position = get_global_mouse_position()
		menu.visible = true
	#movimentação via WASD
	if Input.is_action_just_pressed("ui_up"):
		pos_index.y-=1
		_update_position()
	elif Input.is_action_just_pressed("ui_down"):
		pos_index.y+=1
		_update_position()
	elif Input.is_action_just_pressed("ui_left"):
		pos_index.x -=1
		_update_position()
	elif Input.is_action_just_pressed("ui_right"):
		pos_index.x +=1
		_update_position()
	#if Input.is_action_just_pressed()
		


func _update_position():
	#define a posição do jogador com base no tile que está
	print(get_node("../socket").boar.get_status())
	global_position = pos_index*Vector2(CELL_SIZE,CELL_SIZE) + Vector2(CELL_SIZE/2,CELL_SIZE/2)
	get_node("../socket")._send_position(pos_index)
