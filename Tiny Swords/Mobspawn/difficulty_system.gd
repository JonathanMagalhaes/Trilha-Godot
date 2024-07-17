extends Node

@export_category("Mob Spawner")
@export var mob_spawner: Mobspawner 

@export_category("Wave System")
@export var initial_difficulty: float = 30.0
@export var spawns_per_minute: float = 30.0
@export var wave_duration: float = 10.0
@export var break_intensity: float = 0.25

var time: float = 0.0

func _process(delta: float) -> void:
	#Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Temporizador
	time += delta
	var time_in_minutes = time / 60.0
	# Dificuldade Linear
	var spawn_rate = initial_difficulty + spawns_per_minute * time_in_minutes
	
	# Sistema de Ondas
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	spawn_rate *= wave_factor
	
	# Aplica Dificuldade
	mob_spawner.mobs_per_minute = spawn_rate
	
	
