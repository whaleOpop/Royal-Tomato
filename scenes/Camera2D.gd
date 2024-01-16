extends Camera2D

@onready var player:Player=  $"../TomatoPrefab"
@onready var marker=$"../TomatoPrefab".get_child(4).get_child(1)

var player_pos: Vector2
var marker_pos: Vector2

func _process(_delta):
	player_pos = player.global_position
	marker_pos = marker.global_position
	global_position = player_pos + (marker_pos - player_pos) / 2
