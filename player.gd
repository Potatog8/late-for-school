extends CharacterBody2D

@export var speed = 85
@export var speedMultiplier = 2.0
@export var gravity = 10
@export var jumpspeed = 250

var wallslide = 4


var last_direction = 1

func _physics_process(_delta: float) -> void:
	
	var was_on_floor
	var direction : Vector2

	if Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
	else:
		direction.x = 0
		
	if Input.is_action_pressed("run"):
		velocity.x = direction.x * (speed * speedMultiplier)
	else:
		velocity.x = direction.x * speed
		
	if Input.is_action_pressed("jump") and (is_on_floor() or !$CoyoteTimer.is_stopped()):
		velocity.y = -jumpspeed
		
	if not is_on_floor() and not is_on_wall():
		velocity.y += gravity
		
	if is_on_wall() and direction.x > 0 and Input.is_action_pressed("right") and velocity.y > 0:
		velocity.y = gravity * wallslide
	if is_on_wall() and direction.x < 0 and Input.is_action_pressed("left") and velocity.y > 0:
		velocity.y = gravity * wallslide
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		$CoyoteTimer.start()
	
	if Input.is_action_pressed("jump") or velocity.y > 0:
		jump_anim(direction.x)
	elif Input.is_action_pressed("run") and direction.length() > 0:
		last_direction = direction.x
		run_anim(direction.x)
	elif abs(direction.x) > 0:
		last_direction = direction.x
		walk_anim(direction.x)
	else:
		idle_anim(last_direction)




func jump_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("jump")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("jump") 
		
func run_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("run")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("run") 
	
func walk_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("walk")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("walk")

func idle_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("idle")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("idle")
