class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3

@export_category("Sword")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene

@export_category("Stats")
@export var health: int = 100
@export var max_health: int = 100
@export var gold_amount: int = 0

@export_category("Damage Intake")
@export var damage_amount = 0
@export var death_prefab: PackedScene


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: ProgressBar = $HealthBar

var input_vector: Vector2 = Vector2(0,0)
var attack_direction: Vector2

var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal gold_collected(value: int)

func _ready():
	GameManager.player = self
	gold_collected.connect(func(value: int): GameManager.gold_counter += 1)

func _process(delta: float) -> void:
	GameManager.player_position = position
	## Ler Input
	read_input()
	
	## Cooldown do Ataque
	update_attack_cooldown(delta)
	
	## Processar animação e rotação de sprite
	play_run_idle_animation()
	rotate_sprite()
	
	## Ataque
	if Input.is_action_just_pressed("attack"):
		attack()
		
	## Processar Dano
	update_hitbox_detection(delta)
	
	## Ritual
	update_ritual(delta)
	
	## Atualizar Health Bar
	health_bar.max_value = max_health
	health_bar.value = health

func update_attack_cooldown(delta: float) -> void:
	## Atualizar Temporizador do Ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animation_player.play("Idle")

func rotate_sprite() -> void:
	## Girar Sprite
	if input_vector.x > 0:
		# Desmarcar FlipH do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		# Marcar FlipH do Sprite2D
		sprite.flip_h = true

func play_run_idle_animation() -> void:
	## Tocar a Animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("Run")
			else:
				animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	## Modificar a Velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.1)
	move_and_slide()

func read_input() -> void:
	## Obter o Input Vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	## Apagar deadzone do Input_Vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
	
	## Atualizar o "is_running"
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func attack() -> void:
	if is_attacking:
		return

	## Tocar Animação de Ataque
	animation_player.play("Attack_Side_1")
	
	## Configurar Temporizador
	attack_cooldown = 0.6
	
	## Marcar Ataque
	is_attacking = true
	
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("Jogador recebeu dano de ", amount, ". A vida total é de ", health, "/", max_health)
	
	## Piscar Inimigo
	modulate =  Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	## Processar Morte
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Jogador morreu!")
	queue_free()

func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health
	print("Jogador recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health)

func update_hitbox_detection(delta: float) -> void:
	## Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	## Frequência
	hitbox_cooldown = 0.5
		
	## Detectar Inimigos
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			damage(damage_amount)

func update_ritual(delta: float) -> void:
	# Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	
	# Resetar temporizador
	ritual_cooldown = ritual_interval
	
	# Criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


