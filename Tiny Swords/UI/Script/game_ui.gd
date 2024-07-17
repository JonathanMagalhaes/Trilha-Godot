extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var gold_label: Label = %GoldLabel


func _process(delta: float):
	timer_label.text = GameManager.time_elapsed_string
	gold_label.text = str(GameManager.gold_counter)
