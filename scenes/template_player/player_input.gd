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

# To identify the player
var last_weapon_slot: int = -1  # Track the last weapon slot to prevent unnecessary RPCs

func _ready():
	
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	inventory.armors_slots.resize(3)
	inventory.supplies_slots.resize(6)
	inventory.guns_slots.resize(2)
# Применяем функцию ко всем слотам
	fill_slots_with_unique_objects(inventory.armors_slots)
	fill_slots_with_unique_objects(inventory.supplies_slots)
	fill_slots_with_unique_objects(inventory.guns_slots)

func fill_slots_with_unique_objects(slots: Array):
	for i in range(slots.size()):
		slots[i] = InventorySlot.new()



func _process(delta):
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
	
@rpc("call_local")
func auto_shoot():
	auto_shooting = true
	
@rpc("call_local")
func single_shoot():
	single_shooting = true

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
	weapon_slot = slot_index

# Picking up a weapon
@rpc("call_remote")
func pick_up_weapon(area: Object):
	if not inventory_open:
		if area is Area3D:
			if area.has_method("collect"):
				area.collect(inventory)
		else:
			print("Error: Argument is not of type Area3D.")


func _on_pick_up_area_entered(area: Area3D):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		pick_up_weapon.rpc(area)

func _on_pick_up_area_exited(area: Area3D):
	# Logic when exiting the pickup area, if needed
	pass
