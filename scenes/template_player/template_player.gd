extends Node3D

@onready var camera_3d: Camera3D = $Camera3D

@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

func _ready():
	if player == multiplayer.get_unique_id():
		camera_3d.current = true
