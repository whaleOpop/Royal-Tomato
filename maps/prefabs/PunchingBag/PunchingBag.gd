extends StaticBody2D

@onready var sprite =$"../Sprite2D"

@onready var label=$"../Label"
@onready var label2=$"../Label2"
var timer : Timer
var timerAnim : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer=Timer.new()
	timer.wait_time=10
	timer.one_shot=false
	timer.connect("timeout",_on_Timer_timeout)
	add_child(timer)
	timer.start()
	timerAnim=Timer.new()
	
	pass # Replace with function body.
func _process(delta):
	pass

func _on_Timer_timeout_anim():
	sprite.play("idle")
	pass

func _on_Timer_timeout():
	label.text = "0"
	label2.text=label.text
	pass
func take_damage(damage):
	
	var old_damage=str_to_var(label.text)
	label.text=var_to_str(old_damage+damage)
	label2.text=label.text
	timerAnim.stop()
	sprite.stop()
	timerAnim.wait_time=1
	timerAnim.one_shot=false
	timerAnim.connect("timeout",_on_Timer_timeout_anim)
	add_child(timerAnim)
	sprite.play("hit")
	timerAnim.start()
	
