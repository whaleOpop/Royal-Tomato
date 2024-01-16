extends CharacterBody2D
class_name Player 

#Параметры
@export var speed:float = 100.0
@export var gravity:float = 14.0
@export var jump_strength :int= 220


const FLOOR_HEIGHT : int = 16
const FLOOR_RECT: Vector2 = Vector2(32, 32)

const COLLIDER_WIDTH = 18
const COLLIDER_HEIGHT = 1
const COLLIDER_POSITION_SHIFT = Vector2(COLLIDER_WIDTH, COLLIDER_HEIGHT) / 2
const collider: Rect2 = Rect2(COLLIDER_POSITION_SHIFT, COLLIDER_POSITION_SHIFT * 2)



#Контролируемые объекты
@onready var sprite =$Appearance
@onready var shadow =$Shadow
@onready var shadow_init_scale = shadow.scale.x

#Отслеживаемые поверхности
@export var floor_paths:Array
var floors: Array

#Состояния персонажа
var vertical_velocity: float = 0.0

var elevation: float = 0
var is_jumping: bool = false

var current_floor: int = -1

func _process(_delta):
# warning-ignore:integer_division
	change_floor(int(elevation) / FLOOR_HEIGHT)
	get_jump_input()
	get_movement_direction()
	draw_shadow()


	
	
func _ready():
	if(floor_paths.is_empty()):
		push_error("floor_paths персонажа не содержит путей к поверхностям сцены")
	
	#Преобразуем заданные пути к этажам в инспекторе в TileMap и добавляем в floors
	for fl in floor_paths:
		floors.append(get_node(fl) as TileMap)
	
	change_floor(0)
#	debug_print_c()

func _physics_process(delta):
	#collider.position = global_position - COLLIDER_POSITION_SHIFT - Vector2(0, elevation)
	#velocity = get_movement_direction() * speed
	#velocity = move_and_slide(velocity)
	vertical_movement(delta)

func get_movement_direction():
	var direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()

func get_jump_input():
	if(!is_jumping && Input.is_action_pressed("jump")):
		is_jumping = true;
		vertical_velocity = jump_strength

func vertical_movement(delta: float):
	if(!is_above_tile()): is_jumping = true

	if(is_jumping):
		elevation += delta * vertical_velocity

		var current_floor_height: float = current_floor * FLOOR_HEIGHT
		if(elevation <= current_floor_height && is_above_tile()):
			is_jumping = false
			elevation = current_floor_height
			vertical_velocity = 0
			sprite.position.y = -elevation
			shadow.scale = Vector2(shadow_init_scale, shadow_init_scale)
			return

		sprite.position.y = -elevation

		vertical_velocity = clamp(vertical_velocity - gravity, -jump_strength, jump_strength)

#Меняет этаж
func change_floor(index: int):
# warning-ignore:narrowing_conversion
	index = clamp(index, 0, floors.size() - 1)
	
	if(current_floor == index): return
	
	current_floor = index
# warning-ignore:narrowing_conversion
	collision_layer = pow(2, index)
# warning-ignore:narrowing_conversion
	collision_mask = pow(2, index)

#Проверяет, есть ли под персонажем пол текущего этажа
func is_above_tile():
	var tilemap: TileMap = floors[current_floor]
	
	var cell_coords:Vector2 = tilemap.local_to_map(tilemap.to_local(global_position))
	var top_cell_coords = cell_coords + Vector2.UP
	var right_cell_coords = cell_coords + Vector2.RIGHT
	var down_cell_coords = cell_coords + Vector2.DOWN
	var left_cell_coords = cell_coords + Vector2.LEFT
	
	for coord in [cell_coords, top_cell_coords, right_cell_coords, down_cell_coords, left_cell_coords]:
		if(tilemap.get_cell_source_id(0,coord) == -1): continue
		
		coord = tilemap.to_global(tilemap.local_to_map(coord))
		var cell_collider = Rect2(coord - Vector2(0, FLOOR_HEIGHT * current_floor), FLOOR_RECT)
		if(collider.intersects(cell_collider)):
			return true
	
	return false

func draw_shadow():
	for i in range(floors.size(), 0, -1):
		var tilemap: TileMap = floors[i - 1]
		if(tilemap.get_cell_source_id(0,tilemap.local_to_map(tilemap.to_local(global_position))) != -1):


			var a = shadow_init_scale - (elevation - ((i - 1) * FLOOR_HEIGHT)) / 50
			var shadow_scale = clamp(a, 0.2, shadow_init_scale)
			shadow.scale = Vector2(shadow_scale, shadow_scale)
			shadow.position.y = -(i - 1) * FLOOR_HEIGHT
# warning-ignore:narrowing_conversion
			shadow.z_index = -shadow.position.y / FLOOR_HEIGHT
			return


