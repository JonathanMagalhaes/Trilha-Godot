extends Node2D

@export var gold_amount: int = 0

func _ready():
	$Area2D.body_entered.connect(on_body_entered)
	

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player: Player = body
		player.gold_amount += 1
		
		player.gold_collected.emit(gold_amount)
		
		print("Coletou ", player.gold_amount, " de gold")
		queue_free()

