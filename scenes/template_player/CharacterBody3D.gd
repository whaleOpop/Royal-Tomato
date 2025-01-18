extends CharacterBody3D

@export var CAMERA: Camera3D
@export var camera_offset: Vector3 = Vector3(0, 2, -5)
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 15
@export var CAMERA_SMOOTHING = 5.0

@onready var invVisual = $"../CanvasLayer/InventoryPlayer"
@onready var animator = $AnimationPlayer
@onready var hand = $Hand

var state_machine: Dictionary
var current_state

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var player := 1:
	set(id):
		player = id
		if has_node("PlayerInput"):  # Проверяем существование узла
			$"PlayerInput".set_multiplayer_authority(id)
		else:
			print_debug("PlayerInput node not found!")

@onready var input = $"PlayerInput" # Ссылка на узел MultiplayerSynchronizer

var inventory: Inventory
var current_weapon_slot: int = -1  # Отслеживаем текущий слот оружия

func _ready():
	if player == multiplayer.get_unique_id():
		if CAMERA:
			CAMERA.current = true

	add_to_group("player")

	if input:
		inventory = input.inventory
	else:
		print_debug("Input node is null!")

	# Инициализируем машину состояний
	state_machine = {
		"IDLE": IdleState.new(),
		"RUN_UP": RunUpState.new(),
		"RUN_DOWN": RunDownState.new(),
		"RUN_RIGHT": RunRightState.new(),
		"RUN_LEFT": RunLeftState.new(),
		"RUN_UP_LEFT": RunUpLeftState.new(),
		"RUN_UP_RIGHT": RunUpRightState.new(),
		"RUN_DOWN_LEFT": RunDownLeftState.new(),
		"RUN_DOWN_RIGHT": RunDownRightState.new(),
		"INVENTORY": InventoryState.new()
	}
	change_state("IDLE")

func _process(delta):
	if CAMERA:
		update_camera(delta)

	if current_state:
		current_state.update(self, delta)

	if current_state != state_machine["INVENTORY"]:
		rotate_towards_mouse()

	# Управление открытием/закрытием инвентаря
	if input and input.inventory_open:
		if current_state != state_machine["INVENTORY"]:
			if invVisual:
				invVisual.open()
			change_state("INVENTORY")
	else:
		if current_state == state_machine["INVENTORY"]:
			if invVisual:
				invVisual.close()
			change_state("IDLE")

	# Обработка переключения оружия на основе ввода
	if input and input.weapon_slot >= 0:
		_switch_weapon(input.weapon_slot)

	if hand.get_children():
		var gun = hand.get_child(0)
		if input.single_shooting:
			match gun.current_mode:
				gun.FireMode.SINGLE:
					gun.single_fire()
				gun.FireMode.BURST:
					gun.burst_fire()
			input.single_shooting = false
		if Input.is_action_pressed("ui_fire") and gun.current_mode == gun.FireMode.AUTO:
			gun.auto_fire()
			input.auto_shooting = false

		if Input.is_action_just_released("ui_fire"):
			# Сброс флага для одиночного режима
			if gun.current_mode == gun.FireMode.SINGLE:
				gun.can_shoot = true
			# Сброс счётчика выстрелов для режима очереди
			if gun.current_mode == gun.FireMode.BURST:
				gun.shots_fired_in_burst = 0
			input.single_shooting = false

func _physics_process(delta):
	if current_state != state_machine["INVENTORY"]:
		handle_physics(delta)

func update_camera(delta):
	if CAMERA:
		var rotation_basis = Basis(Vector3(0, 1, 0), deg_to_rad(CAMERA.rotation_degrees.y))
		var transformed_offset = rotation_basis * camera_offset
		var target_position = global_transform.origin + transformed_offset
		var current_position = CAMERA.global_transform.origin
		CAMERA.global_transform.origin = current_position.lerp(target_position, CAMERA_SMOOTHING * delta)

func rotate_towards_mouse():
	if CAMERA:
		var from = CAMERA.project_ray_origin(input.mouse_position)
		var to = from + CAMERA.project_ray_normal(input.mouse_position) * 1000

		var ray_params = PhysicsRayQueryParameters3D.new()
		ray_params.from = from
		ray_params.to = to
		ray_params.collide_with_areas = true
		ray_params.collide_with_bodies = true
		ray_params.exclude = [self]

		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(ray_params)

		if result.size() > 0:
			adjust_hand_orientation(result.position, input.mouse_position)

func adjust_hand_orientation(target_position: Vector3, mouse_pos: Vector2):
	if is_instance_valid(hand) and is_instance_valid(CAMERA):
		var character_pos_screen = CAMERA.unproject_position(global_transform.origin)
		if mouse_pos.x < character_pos_screen.x:
			scale.x = -abs(scale.x)
			hand.scale.z = -abs(hand.scale.z)
			hand.scale.y = -abs(hand.scale.y)
		else:
			scale.x = abs(scale.x)
			hand.scale.z = abs(hand.scale.z)
			hand.scale.y = abs(hand.scale.y)

		hand.look_at(target_position, Vector3.UP)

func handle_physics(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if input:
		if input.cameraLeft and CAMERA:
			sync_camera_rotation_rpc(CAMERA.rotation_degrees.y + 90)
			input.cameraLeft = false
		if input.cameraRight and CAMERA:
			sync_camera_rotation_rpc(CAMERA.rotation_degrees.y - 90)
			input.cameraRight = false

		if input.jumping and is_on_floor():
			velocity.y = JUMP_VELOCITY
			input.jumping = false

		var input_dir = input.direction

		if CAMERA:
			var camera_basis = CAMERA.global_transform.basis
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

@rpc("call_local")
func sync_camera_rotation_rpc(rotation_y: float):
	if CAMERA:
		CAMERA.rotation_degrees.y = rotation_y
		rotation_degrees.y = rotation_y

func _switch_weapon(slot_index):
	if slot_index == current_weapon_slot:
		return  # Выходим из функции, если выбран тот же слот

	current_weapon_slot = slot_index  # Обновляем текущий слот

	if is_instance_valid(hand):
		# Удаляем текущее оружие в руке, если есть
		if hand.get_child_count() > 0:
			hand.get_child(0).queue_free()

		# Проверяем слот оружия и экипируем оружие, если оно доступно
		if inventory and inventory.guns_slots.size() > slot_index and inventory.guns_slots[slot_index].item != null:
			var gun = inventory.guns_slots[slot_index].item.scene.instantiate()
			gun.rotation_degrees.y = 180
			hand.add_child(gun)

			# Синхронизируем переключение оружия на всех клиентах
			sync_weapon_switch_rpc(slot_index)
		else:
			print_debug("No gun available in slot: ", slot_index)
	else:
		print_debug("Hand node is null or invalid!")

@rpc("call_local")
func sync_weapon_switch_rpc(slot_index):
	_switch_weapon(slot_index)
	
func change_state(new_state: String):
	if current_state:
		current_state.exit(self)  # Вызываем метод выхода из текущего состояния
	current_state = state_machine.get(new_state, null)  # Устанавливаем новое состояние
	if current_state:
		current_state.enter(self)  # Вызываем метод входа в новое состояние
