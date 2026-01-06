extends CharacterBody2D #Parent Node

@export var speed = 160 # used for speed calculations
@export var speedMultiplier = 30 #how much the character velocity will increase / decrease by
@export var gravity = 10 #used to pull player down
@export var jumpspeed = 50 #used to calculate players upward momentum during jump

var wallslide = 4 #used to calculate wallslide speed


var last_direction = 1 #stores the direction the character most recently faced

func _physics_process(_delta: float) -> void:
	
	var was_on_floor
	var direction : Vector2

	if Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
	else:
		direction.x = 0
		
	if Input.is_action_pressed("run") and (!is_on_wall() or is_on_floor()):
		if direction.x > 0:
			if $RunTimer.is_stopped():
				if velocity.x < 1:
					velocity.x += speed
				if velocity.x > 0:
					velocity.x += speedMultiplier
				$RunTimer.start()
				if velocity.x > 210:
					velocity.x = 210

		if direction.x < 0:
			if $RunTimer.is_stopped():
				if velocity.x > -1:
					velocity.x -= speed
				if velocity.x < 0:
					velocity.x -= speedMultiplier
				$RunTimer.start()
				if velocity.x < -210:
					velocity.x = -210
		
		if direction.x == 0:
			if last_direction > 0:
				velocity.x -= speed * 0.1
				if velocity.x < 0:
					velocity.x = 0
			if last_direction < 0:
				velocity.x += speed * 0.1
				if velocity.x > 0:
					velocity.x = 0

	if !Input.is_action_pressed("run") and (!is_on_wall() or is_on_floor()) and $WalljumpTimer.is_stopped():
		if direction.x > 0:
			if $RunTimer.is_stopped():
				if velocity.x < 1:
					velocity.x += speed * 0.5
				if velocity.x > 0:
					velocity.x += speedMultiplier
				$RunTimer.start()
				if velocity.x > 85:
					velocity.x = 85
					
		if direction.x < 0:
			if $RunTimer.is_stopped():
				if velocity.x > -1:
					velocity.x -= speed * 0.5
				if velocity.x < 0:
					velocity.x -= speedMultiplier
				$RunTimer.start()
				if velocity.x < -85:
					velocity.x = -85
					
		if direction.x == 0:
			velocity.x = 0


	if Input.is_action_pressed("jump") and (is_on_floor_only() or !$CoyoteTimer.is_stopped()):
		velocity.y -= jumpspeed
		if velocity.y < -250:
			velocity.y = -250

		
	if !is_on_floor():
		velocity.y += gravity
		
	if is_on_wall() and direction.x > 0 and Input.is_action_pressed("right") and !is_on_floor():
		if !Input.is_action_pressed("jump"):
			velocity.y = gravity * wallslide
			velocity.x = direction.x * speed * 0.5
		if Input.is_action_just_pressed("jump"):
			$WalljumpTimer.start()
			velocity.x = -direction.x * speed * 2
			velocity.y = -200


	if is_on_wall() and direction.x < 0 and Input.is_action_pressed("left") and !is_on_floor():
		if !Input.is_action_pressed("jump"):
			velocity.y = gravity * wallslide
			velocity.x = direction.x * speed * 0.5
		if Input.is_action_just_pressed("jump"):
			$WalljumpTimer.start()
			velocity.x = -direction.x * speed * 2
			velocity.y = -200
	
	was_on_floor = is_on_floor()

	
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		$CoyoteTimer.start()
	elif Input.is_action_pressed("jump") or velocity.y > 0:
		jump_anim(direction.x)
	elif Input.is_action_pressed("run") and direction.length() > 0:
		last_direction = direction.x
		run_anim(direction.x)
	elif abs(direction.x) > 0:
		last_direction = direction.x
		walk_anim(direction.x)
	else:
		idle_anim(last_direction)


func walljump_anim(direction):
	if direction > 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("jump")
	if direction < 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("jump")

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
