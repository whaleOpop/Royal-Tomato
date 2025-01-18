extends MultiplayerSynchronizer

# Synchronized properties
@export var jumping := false
@export var single_shooting := false
@export var auto_shooting := false
@export var cameraLeft := false
@export var cameraRight := false
@export var inventory_open := false
@export var direction := Vector2()
@export var mouse_position := Vector2()
@export var hand_rotation := Vector3()
@export var weapon_slot := -1
var inventory = Inventory.new()
@onready var invVis = $"../../CanvasLayer/InventoryPlayer"
@onready var hand = $"../Hand"
# To identify the player
var last_weapon_slot: int = -1  # Track the last weapon slot to prevent unnecessary RPCs

func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	inventory.armors_slots.resize(3)
	inventory.supplies_slots.resize(6)
	inventory.guns_slots.resize(2)
	# Apply function to all slots
	fill_slots_with_unique_objects(inventory.armors_slots)
	fill_slots_with_unique_objects(inventory.supplies_slots)
	fill_slots_with_unique_objects(inventory.guns_slots)
	invVis.inventory = inventory

func fill_slots_with_unique_objects(slots: Array):
	for i in range(slots.size()):
		slots[i] = InventorySlot.new()

func _process(delta):
	if is_local_player():
		# Sync input direction for movement
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

		# Sync mouse position and hand rotation for aiming
		mouse_position = get_viewport().get_mouse_position()
		hand_rotation = $"../Hand".rotation_degrees
		
		# Handle jump input
		if Input.is_action_just_pressed("ui_accept"):
			jump.rpc()

		# Handle camera rotation inputs
		if Input.is_action_just_pressed("camera_left"):
			cameraleft.rpc()
		if Input.is_action_just_pressed("camera_right"):
			cameraright.rpc()

		# Handle inventory toggle
		if Input.is_action_just_pressed("inventory_toggle"):
			toggle_inventory.rpc()

		# Handle weapon switching (1 and 2 keys)
		if Input.is_action_just_pressed("num_1"):
			if last_weapon_slot != 0:
				switch_weapon.rpc(0)
				last_weapon_slot = 0

		elif Input.is_action_just_pressed("num_2"):
			if last_weapon_slot != 1:
				switch_weapon.rpc(1)
				last_weapon_slot = 1
		
		if Input.is_action_just_pressed("ui_fire"):
			single_shoot.rpc()
		
		if Input.is_action_pressed("ui_fire"):
			auto_shoot.rpc()

# Synchronize shooting actions with RPCs
@rpc("call_local")
func single_shoot():
	single_shooting = true
	# Call the gun's single fire function here
	if is_instance_valid(hand) and hand.get_child_count() > 0:
		var gun = hand.get_child(0)
		gun.single_fire()

@rpc("call_local")
func auto_shoot():
	auto_shooting = true
	# Call the gun's auto fire function here
	if is_instance_valid(hand) and hand.get_child_count() > 0:
		var gun = hand.get_child(0)
		gun.auto_fire()


@rpc("call_local")
func jump():
	jumping = true

@rpc("call_local")
func cameraleft():
	cameraLeft = true

@rpc("call_local")
func cameraright():
	cameraRight = true

@rpc("call_local")
func toggle_inventory(): 
	inventory_open = not inventory_open

@rpc("call_local")
func switch_weapon(slot_index):
	if slot_index == last_weapon_slot:
		return  # Выходим из функции, если выбран тот же слот

	last_weapon_slot = slot_index  # Обновляем текущий слот

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
		
		else:
			print_debug("No gun available in slot: ", slot_index)
	else:
		print_debug("Hand node is null or invalid!")


# Picking up a weapon - Synchronize between players when a weapon is picked up
@rpc("call_local")
func pick_up_weapon(area: Object):
	if not inventory_open:
		if area is Area3D:
			if area.has_method("collect"):
				area.collect(inventory)

# Check if the current player has authority (only the local player should execute this)
func is_local_player() -> bool:
	return get_multiplayer_authority() == multiplayer.get_unique_id()
	
# Trigger weapon pick-up when entering the area
func _on_pick_up_area_entered(area: Area3D):
	pick_up_weapon(area)

# Handle when exiting the pickup area (if any additional logic is needed)
func _on_pick_up_area_exited(area: Area3D):
	pass
