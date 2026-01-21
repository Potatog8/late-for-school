extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D #variable to store the sprite

func _ready():
	sprite.play("spin")  # animates sprite
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("add_coin"): #checks if player is the one who touched the coin
		body.add_coin() #calls add coin function from player
		queue_free()  # remove coin after collection
