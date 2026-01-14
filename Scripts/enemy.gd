extends CharacterBody2D

@export var speed: float = 60.0

var direction := 1  # starts facing right

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kill_area: Area2D = $KillArea

func _ready():
	sprite.play("walk")
	sprite.flip_h = false
	kill_area.body_entered.connect(_on_kill_area_body_entered)

func _physics_process(_delta):
	velocity.x = direction * speed
	move_and_slide()

	if is_on_wall():
		flip()

func flip():
	direction *= -1
	sprite.flip_h = direction == -1

func _on_kill_area_body_entered(body):
	if body.name == "Player":
		if body.has_method("respawn"):
			body.respawn()
