extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("spin")  # your animation must be named "spin"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("add_coin"):
		body.add_coin()
		queue_free()  # remove coin after collection
