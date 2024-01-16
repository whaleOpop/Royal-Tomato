extends RayCast2D

@onready var marker = $Marker
@onready var laser = $Line2D
@onready var appearance = get_parent().get_node("Appearance") as Node2D

const AIM_OFFSET = Vector2(0, -16)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta):
	marker.global_position = get_global_mouse_position()

func _physics_process(_delta):
	position = appearance.position + AIM_OFFSET
	var cast_point = marker.position
	target_position = cast_point
	force_raycast_update()
	
	if(is_colliding()):
		cast_point = to_local(get_collision_point())
	
	laser.points[1] = cast_point
