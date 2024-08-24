extends CharacterBody3D

@export var camera: Camera3D
@export var camera_offset: Vector3 = Vector3(0, 2, -5)

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SMOOTHING = 5.0
@onready var inventory: Inventory =preload("res://scenes/Inventory/ui/inventory/Inventory.tres")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var invVisual = $"../CanvasLayer/InventoryPlayer"
@onready var animator = $AnimationPlayer # Assume your animations are handled by an AnimationPlayer node
@onready var hand = $Hand
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
		"RUN_DOWN_RIGHT": RunDownRightState.new(),
		"INVENTORY": InventoryState.new()  # Add the new Inventory state
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
	
	
	# Rotate character towards the mouse position
	if current_state != state_machine["INVENTORY"]:
		rotate_towards_mouse()

func _physics_process(delta):
	if current_state != state_machine["INVENTORY"]:
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
		if Input.is_action_just_pressed("num_1"):
			if inventory.guns_slots[0]!=null:
				if hand.get_child(0)!=null:
					hand.get_child(0).queue_free()
					
				#hand.add_child()
			else:
				hand.get_child(0).queue_free()
		if Input.is_action_just_pressed("num_2"):
			if inventory.guns_slots[0]!=null:
				if hand.get_child(0)!=null:
					hand.get_child(0).queue_free()
			
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
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.exclude = [self]

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	if result.size() > 0:
		var target_position = result.position

		var character_pos_screen = camera.unproject_position(global_transform.origin)

		if mouse_pos.x < character_pos_screen.x:
			scale.x = -abs(scale.x)
			hand.scale.z = -abs(hand.scale.z)
			hand.scale.y = -abs(hand.scale.y)
		else:
			scale.x = abs(scale.x)
			hand.scale.z = abs(hand.scale.z)
			hand.scale.y = abs(hand.scale.y)

		hand.look_at(target_position, Vector3.UP)

func change_state(new_state: String):
	if current_state:
		current_state.exit(self)
	current_state = state_machine.get(new_state, null)
	if current_state:
		current_state.enter(self)

func _input(event: InputEvent):
	if event.is_action_pressed("inventory_toggle"):
		toggle_inventory()

func toggle_inventory():
	if current_state == state_machine["INVENTORY"]:
		invVisual.close() 
		change_state("IDLE")  # Exit InventoryState
	else:
		invVisual.open() 
		change_state("INVENTORY")  # Enter InventoryState

func _on_inventory_player_closed():
	pass

func _on_inventory_player_opened():
	pass


func _on_pick_up_area_entered(area: Area3D) -> void:
	if not invVisual.visible:
		if area.has_method("collect"):
			if Input.is_action_pressed("pick_item"):
				area.collect(inventory)
	pass # Replace with function body.


func _on_pick_up_area_exited(area: Area3D) -> void:
	
	pass # Replace with function body.
