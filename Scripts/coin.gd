extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("spin")  # plays spin animation for coin
	body_entered.connect(_on_body_entered) #connects the coin signal

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("add_coin"): #checks if player touches the coin and checks for function add_coin
		body.add_coin() #executes add coin
		queue_free()  # remove coin after collection
