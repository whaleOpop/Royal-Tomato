extends Node3D

@export var muzzle_flash: GPUParticles3D
var gun_model = get_child(0)
@export var fire_rate = 0.1  # Время между выстрелами для автоматического режима
var time_since_last_shot = 0.0  # Время с момента последнего выстрела

enum FireMode { SINGLE, BURST, AUTO }
@export var current_mode = FireMode.SINGLE  # Текущий режим стрельбы

var burst_shots = 3  # Количество выстрелов в очереди
var shots_fired_in_burst = 0  # Счетчик выстрелов в очереди

@onready var gun_barrel = $RayCastNode  # Убедитесь, что путь к RayCast3D корректен

var bullet = preload("res://Bullet.tscn")
var can_shoot = true  # Флаг, который отслеживает возможность выстрела для одиночного режима

func _ready() -> void:
	# Проверка, что gun_barrel правильно инициализирован
	if gun_barrel == null:
		print("Error: gun_barrel not found!")
	else:
		print("gun_barrel initialized successfully")

func _process(delta: float) -> void:
	time_since_last_shot += delta

	if Input.is_action_just_pressed("ui_fire"):
		match current_mode:
			FireMode.SINGLE:
				single_fire()
			FireMode.BURST:
				burst_fire()

	if Input.is_action_pressed("ui_fire") and current_mode == FireMode.AUTO:
		auto_fire()

	if Input.is_action_just_released("ui_fire"):
		# Сброс флага для одиночного режима
		if current_mode == FireMode.SINGLE:
			can_shoot = true
		# Сброс счётчика выстрелов для режима очереди
		if current_mode == FireMode.BURST:
			shots_fired_in_burst = 0

func single_fire() -> void:
	if can_shoot and time_since_last_shot >= fire_rate:
		shoot()
		can_shoot = false  # Запретить стрельбу до следующего нажатия
		time_since_last_shot = 0.0

func burst_fire() -> void:
	if time_since_last_shot >= fire_rate and shots_fired_in_burst < burst_shots:
		shoot()
		shots_fired_in_burst += 1
		time_since_last_shot = 0.0

func auto_fire() -> void:
	if time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0.0

func shoot() -> void:
	if gun_barrel == null:
		print("Error: gun_barrel is null during shoot")
		return

	var instance = bullet.instantiate()

	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis

	# Добавление пули в корневой узел или другой независимый узел
	get_tree().root.add_child(instance)

	if muzzle_flash:
		muzzle_flash.emitting = true