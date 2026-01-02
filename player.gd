extends CharacterBody2D

@export var speed = 85
@export var speedMultiplier = 2.0

var last_direction := Vector2(1,0)

func _physics_process(_delta: float) -> void:
	var direction
	if Input.is_action_pressed("left"):
		direction = Vector2(-1, 0)
	elif Input.is_action_pressed("right"):
		direction = Vector2(1, 0)
	else:
		direction = Vector2(0,0)
		
	if Input.is_action_pressed("run"):
		velocity = direction * (speed * speedMultiplier)
	else:
		velocity = direction * speed
	
	move_and_slide()
	
	if Input.is_action_pressed("run") and direction.length() > 0:
		last_direction = direction
		run_anim(direction)
	elif direction.length() > 0:
		last_direction = direction
		walk_anim(direction)
	else:
		idle_anim(last_direction)
	
	
func run_anim(direction):
	if direction.x < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("run")
	if direction.x > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("run") 
	
func walk_anim(direction):
	if direction.x < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("walk")
	if direction.x > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("walk")

func idle_anim(direction):
	if direction.x < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("idle")
	if direction.x > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("idle")
