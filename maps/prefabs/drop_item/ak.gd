extends Node2D

var player_in_area=false

@export var item:InvItem
var player=null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("pickItem"):
			print("Yes")
			player.collect(item)
			queue_free()
	pass


func _on_pickable_area_body_entered(body):
	if body.has_method("player"):
		player_in_area=true
		player=body
	pass # Replace with function body.


func _on_pickable_area_body_exited(body):
	if body.has_method("player"):
		player_in_area=false
		player=null
	pass # Replace with function body.
