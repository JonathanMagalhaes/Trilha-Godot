extends Node

@export var speed = 1.0

var enemy: Enemy
var sprite: AnimatedSprite2D

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	pass

func _physics_process(delta: float) -> void:
	#Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Calcula direção
	var player_position = GameManager.player_position
	var diference = player_position - enemy.position
	var input_vector = diference.normalized()
	
	# Movimento
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()

	## Girar Sprite
	if input_vector.x > 0:
		# Desmarcar FlipH do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		# Marcar FlipH do Sprite2D
		sprite.flip_h = true
