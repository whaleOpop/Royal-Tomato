extends CharacterBody2D
class_name Player 

#Параметры
@export var speed:float = 100.0
@export var gravity:float = 14.0
@export var jump_strength :int= 220

@export var inv:Inv



const FLOOR_HEIGHT : int = 16
const FLOOR_RECT: Vector2 = Vector2(32, 32)

const COLLIDER_WIDTH = 18
const COLLIDER_HEIGHT = 2
const COLLIDER_POSITION_SHIFT = Vector2(COLLIDER_WIDTH, COLLIDER_HEIGHT)
var collider: Rect2 = Rect2(COLLIDER_POSITION_SHIFT, COLLIDER_POSITION_SHIFT *2)



#Контролируемые объекты
@onready var sprite =$Appearance
@onready var shadow =$Shadow
@onready var shadow_init_scale = shadow.scale.x
@onready var anim = $AnimationPlayer

#Отслеживаемые поверхности
@export var tilemaps:TileMap


#Состояния персонажа

var vertical_velocity: float = 0.0

var elevation: float = 0
var is_jumping: bool = false

var current_floor: int = -1

func _ready():
	if(tilemaps.get_layers_count()==0):
		push_error("floor_paths персонажа не содержит путей к поверхностям сцены")
	change_floor(0)

func _process(_delta):
# warning-ignore:integer_division
	change_floor(int(elevation) / FLOOR_HEIGHT)
	get_jump_input()
	draw_shadow()
	jab()

	
	


func _physics_process(delta):
	collider.position = global_position - COLLIDER_POSITION_SHIFT - Vector2(0, elevation)

	get_movement_direction()
	move_and_slide()
	vertical_movement(delta)
	
	

func get_movement_direction():
	var direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	
	update_anim(direction)

func get_jump_input():
	if(!is_jumping and Input.is_action_pressed("jump")):
		is_jumping = true;
		vertical_velocity = jump_strength
		

func vertical_movement(delta: float):
	if not is_above_tile():
		is_jumping = true

	if is_jumping:
		elevation += vertical_velocity * delta
		vertical_velocity += gravity * delta

		var current_floor_height: float = current_floor * FLOOR_HEIGHT
		if elevation <= current_floor_height and is_above_tile():
			is_jumping = false
			elevation = current_floor_height
			vertical_velocity = 0

	sprite.position.y = -elevation

	vertical_velocity = clamp(vertical_velocity - gravity, -jump_strength, jump_strength)


#Меняет этаж
func change_floor(index: int):
	index = clamp(index, 0, tilemaps.get_layers_count()-1)
	if current_floor == index:
		return
	current_floor = index
	collision_layer = 1 << index
	collision_mask = 1 << index
	
	
	
func is_above_tile():

	
	var cell_coords = tilemaps.local_to_map(tilemaps.to_local(global_position))
	var top_cell_coords = tilemaps.get_neighbor_cell(cell_coords,TileSet.CELL_NEIGHBOR_TOP_SIDE)
	var right_cell_coords = tilemaps.get_neighbor_cell(cell_coords,TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
	var down_cell_coords = tilemaps.get_neighbor_cell(cell_coords,TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	var left_cell_coords = tilemaps.get_neighbor_cell(cell_coords,TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	
	
	for coord in [cell_coords, top_cell_coords, right_cell_coords, down_cell_coords, left_cell_coords]:
		if(tilemaps.get_cell_source_id(current_floor,coord) == -1): continue
		
		coord = tilemaps.to_global(tilemaps.map_to_local(coord))
		var cell_collider = Rect2(coord - Vector2(0, FLOOR_HEIGHT * current_floor), FLOOR_RECT)
		if(collider.intersects(cell_collider)):
			return true
	
	return false

var animlock = false
func update_anim(direction):

	if not animlock:
		if direction.x!= 0 ||  direction.y!= 0:

			if direction.x>0:
				anim.play("run")
			elif direction.x<0:
			
				anim.play("run")
				
			elif direction.y>0:
				
				anim.play("runDown")
			elif direction.y<0:
				
				anim.play("runUp")
		else:
			anim.play("idle")



func draw_shadow():
	for i in range(tilemaps.get_layers_count(), 0, -1):
		#var tilemap: TileMap = floors[i - 1]
		if(tilemaps.get_cell_source_id(i-1,tilemaps.local_to_map(tilemaps.to_local(global_position))) != -1):


			var a = shadow_init_scale - (elevation - ((i - 1) * FLOOR_HEIGHT)) / 50
			var shadow_scale = clamp(a, 0.2, shadow_init_scale)
			shadow.scale = Vector2(shadow_scale, shadow_scale)
			shadow.position.y = -(i - 1) * FLOOR_HEIGHT
			# warning-ignore:narrowing_conversion
			shadow.z_index = -shadow.position.y / FLOOR_HEIGHT
			return

var isJab=false
func jab():
	var tmpSp:float=100
	_on_animation_player_animation_finished("jab")
	if  Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not isJab:
		tmpSp=speed
		speed=0.0
		animlock=true
		anim.play("jab")
		isJab=true
		
	else:
		animlock=false	
		speed=tmpSp
	pass
	
func _on_animation_player_animation_finished(anim_name):

	if anim_name=="jab":
		isJab=false
	


func _on_area_2d_body_entered(body):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var random_int_num = rng.randi_range(10, 15)
	
	print(body.get_groups())
	if body.is_in_group("hit"):
		print(body)
		body.take_damage(random_int_num)
	else:
		pass # Replace with function body.


func collect(item):
	inv.insert(item)

func player():
	pass
