extends CharacterBody2D

@export var speed: float = 60.0 # enemy speed

var direction := 1  # starts facing right

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kill_area: Area2D = $KillArea

func _ready():
	sprite.play("walk") #play walk animation
	sprite.flip_h = false
	kill_area.body_entered.connect(_on_kill_area_body_entered) #connects the enemy hitbox signal

func _physics_process(_delta):
	velocity.x = direction * speed #calculate velocity
	move_and_slide() #adds movement

	if is_on_wall():
		flip() #runs flip

func flip():
	direction *= -1 #flips the current direction
	sprite.flip_h = direction == -1 #sets flip to true if direction is -1, else its set to false

func _on_kill_area_body_entered(body): 
	if body.name == "Player": #If player enters the hitbox
		if body.has_method("respawn"): #and player has a respawn function
			body.respawn() #run respawn function
