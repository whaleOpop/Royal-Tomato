extends MultiplayerSynchronizer

@onready var weapon: Node3D = null

func _ready() -> void:
	# Ensure the script is running only for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	weapon = get_parent()

# Process function to update shooting synchronization
func _process(delta: float) -> void:
	pass

# RPC function for single fire mode
@rpc("call_local")
func single_fire_rpc() -> void:
	weapon.single_fire()

# RPC function for burst fire mode
@rpc("call_local")
func burst_fire_rpc() -> void:
	weapon.burst_fire()

# RPC function for auto fire mode
@rpc("call_local")
func auto_fire_rpc() -> void:
	weapon.auto_fire()

# Method to switch fire mode (can be expanded if needed)
@rpc("call_local")
func switch_fire_mode_rpc(mode: int) -> void:
	weapon.current_mode = mode
