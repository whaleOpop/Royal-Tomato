extends CharacterBody3D

@export var camera: Camera3D
@export var camera_offset: Vector3 = Vector3(0, 2, -5)

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SMOOTHING = 5.0
@export var inventory: Inventory
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animator = $AnimationPlayer # Assume your animations are handled by an AnimationPlayer node
var state_machine
var current_state

func _ready():
	state_machine = {
		"IDLE": IdleState.new(),
		"RUN_UP": RunUpState.new(),
		"RUN_DOWN": RunDownState.new(),
		"RUN_RIGHT": RunRightState.new(),
		"RUN_LEFT": RunLeftState.new(),
		"RUN_UP_LEFT": RunUpLeftState.new(),
		"RUN_UP_RIGHT": RunUpRightState.new(),
		"RUN_DOWN_LEFT": RunDownLeftState.new(),
		"RUN_DOWN_RIGHT": RunDownRightState.new()
	}
	change_state("IDLE")

func _process(delta):
	# Smoothly follow the player with the camera
	if camera:
		# Apply rotation to the camera offset
		var rotation_basis = Basis(Vector3(0, 1, 0), deg_to_rad(camera.rotation_degrees.y))
		var transformed_offset = rotation_basis * camera_offset

		var target_position = global_transform.origin + transformed_offset
		var current_position = camera.global_transform.origin
		var new_position = current_position.lerp(target_position, CAMERA_SMOOTHING * delta)
		camera.global_transform.origin = new_position

	# Update the current state
	if current_state:
		current_state.update(self, delta)
	
	# Rotate character towards the mouse position
	rotate_towards_mouse()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("camera_left"):
		camera.rotation_degrees.y += 90
		rotation_degrees.y += 90
	if Input.is_action_just_pressed("camera_right"):
		camera.rotation_degrees.y -= 90
		rotation_degrees.y -= 90
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Convert input direction to be relative to the camera's orientation
	var camera_basis = camera.global_transform.basis
	var forward = camera_basis.z.normalized()
	var right = camera_basis.x.normalized()

	var direction = (forward * input_dir.y + right * input_dir.x).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if input_dir.y < 0:
			if input_dir.x < 0:
				change_state("RUN_DOWN_LEFT")
				
			elif input_dir.x > 0:
				change_state("RUN_DOWN_RIGHT")
				
			else:
				change_state("RUN_DOWN")
				
		elif input_dir.y > 0:
			if input_dir.x < 0:
				change_state("RUN_UP_LEFT")
			elif input_dir.x > 0:
				change_state("RUN_UP_RIGHT")
			else:
				change_state("RUN_UP")
		elif input_dir.x < 0:
			change_state("RUN_LEFT")
		elif input_dir.x > 0:
			change_state("RUN_RIGHT")
	else:
		change_state("IDLE")
	
	move_and_slide()
	
func rotate_towards_mouse():
	# Получить позицию мыши
	var mouse_pos = get_viewport().get_mouse_position()

	# Проецируем луч из камеры на плоскость, на которой стоит персонаж
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	# Настраиваем параметры луча
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.exclude = [self]

	# Выполняем лучевой тест
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	# Проверяем, попал ли луч в объект
	if result.size() > 0:
		var target_position = result.position

		# Определяем, находится ли мышка слева или справа от персонажа
		var character_pos_screen = camera.unproject_position(global_transform.origin)
		
		if mouse_pos.x < character_pos_screen.x:
			# Мышка слева, отразить персонажа по горизонтали
			scale.x = -abs(scale.x)
		else:
			# Мышка справа, вернуть нормальный масштаб
			scale.x = abs(scale.x)



func change_state(new_state: String):
	if current_state:
		current_state.exit(self)
	current_state = state_machine.get(new_state, null)
	if current_state:
		current_state.enter(self)


func _on_inventory_player_closed():
	pass # Replace with function body.


func _on_inventory_player_opened():
	pass # Replace with function body.
