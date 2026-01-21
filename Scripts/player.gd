extends CharacterBody2D #Parent Node

@export var speed = 200 # used for speed calculations
@export var speedMultiplier = 30 #how much the character velocity will increase / decrease by
@export var gravity = 10 #used to pull player down
@export var jumpspeed = 120 #used to calculate players upward momentum during jump

var coin_count = 0
var death_count = 0

var can_move = true
var timer_active = true

@onready var coin_label: Label = get_node("/root/Game/UI/CoinLabel")
@onready var death_label: Label = get_node("/root/Game/UI/DeathCounter")
@onready var time_label: Label = get_node("/root/Game/UI/Stopwatch")
@onready var finish_area: Area2D = $Finish

var wallslide = 4 #used to calculate wallslide speed

var spawn_position: Vector2

var last_direction = 1 #stores the direction the character most recently faced
var last_walljump = 0

var seconds = 0

func _ready():
	spawn_position = global_position


func _physics_process(_delta: float) -> void:
	
	var was_on_floor
	var direction : Vector2

	if Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
	else:
		direction.x = 0
		
	if Input.is_action_pressed("run") and (!is_on_wall() or is_on_floor()) and $WalljumpTimer.is_stopped():
		if direction.x > 0:
			if $RunTimer.is_stopped():
				if velocity.x < 1:
					velocity.x += speed
				if velocity.x > 0:
					velocity.x += speedMultiplier
				$RunTimer.start()
				if is_on_floor():
					$Run.play()
				if velocity.x > 210:
					velocity.x = 210

		if direction.x < 0:
			if $RunTimer.is_stopped():
				if velocity.x > -1:
					velocity.x -= speed
				if velocity.x < 0:
					velocity.x -= speedMultiplier
				$RunTimer.start()
				if is_on_floor():
					$Run.play()
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
			$Run.stop()

	if !Input.is_action_pressed("run") and (!is_on_wall() or is_on_floor()) and $WalljumpTimer.is_stopped():
		if direction.x > 0:
			if $RunTimer.is_stopped():
				if velocity.x < 1:
					velocity.x += speed * 0.5
				if velocity.x > 0:
					velocity.x += speedMultiplier
				$RunTimer.start()
				if is_on_floor():
					$Run.play()
				if velocity.x > 85:
					velocity.x = 85
					
		if direction.x < 0:
			if $RunTimer.is_stopped():
				if velocity.x > -1:
					velocity.x -= speed * 0.5
				if velocity.x < 0:
					velocity.x -= speedMultiplier
				$RunTimer.start()
				if is_on_floor():
					$Run.play()
				if velocity.x < -85:
					velocity.x = -85
					
		if direction.x == 0:
			velocity.x = 0
			$Run.stop()


	if Input.is_action_just_pressed("jump") and (is_on_floor() or !$CoyoteTimer.is_stopped()):
		$Jump.play()
		velocity.y = -270

		
	if !is_on_floor():
		velocity.y += gravity
		
	if is_on_wall() and !is_on_floor() and $WalljumpTimer.is_stopped():
		var wall_normal = get_wall_normal()

		if !Input.is_action_just_pressed("jump") and velocity.y > 0:
			velocity.y = gravity * wallslide
			if Input.is_action_pressed("left"):
				velocity.x = -speed
			elif Input.is_action_pressed("right"):
				velocity.x = speed
			else:
				velocity.x = 0

		if Input.is_action_just_pressed("jump"):
			$WalljumpTimer.start()
			velocity.x = wall_normal.x * 320
			velocity.y = -200
			
			last_walljump = wall_normal.x

	
	was_on_floor = is_on_floor()

	
	move_and_slide()
	
	if was_on_floor and !is_on_floor() and !is_on_wall():
		$CoyoteTimer.start()
	elif is_on_wall() and !is_on_floor() and velocity.y >= 0:
		wallslide_anim(direction.x)
	elif Input.is_action_just_pressed("jump") or !is_on_floor():
		jump_anim(direction.x)
	elif Input.is_action_pressed("run") and direction.length() > 0:
		last_direction = direction.x
		run_anim(direction.x)
	elif abs(direction.x) > 0:
		last_direction = direction.x
		walk_anim(direction.x)
	else:
		idle_anim(last_direction)
		
	if timer_active and $TimerDelay.is_stopped():
		seconds += 1
		time_label.text = str(seconds) + "s"
		$TimerDelay.start()
		
	
func add_coin():
	coin_count += 1
	$CollectCoin.play()
	coin_label.text = "Coins: " + str(coin_count)

func respawn():
	$Death.play()
	death_count += 1
	global_position = spawn_position
	death_label.text = "Deaths: " + str(death_count)
	velocity = Vector2.ZERO

func wallslide_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("wallslide")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("wallslide")

func walljump_anim(direction):
	if direction > 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("jump")
	if direction < 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("jump")

func jump_anim(direction):
	var anim_direction = direction

	if last_walljump != 0:
		anim_direction = last_walljump
		$PlayerAnimation.flip_h = anim_direction < 0
		$PlayerAnimation.play("jump")
		last_walljump = 0 

	if anim_direction == 0:
		anim_direction = last_direction
	$PlayerAnimation.flip_h = anim_direction < 0
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

func _on_finish_body_entered(body: Node2D) -> void:
	if body == self:
		timer_active = false
		Nodesender.final_time = time_label.text
		Nodesender.total_coins = coin_label.text
		Nodesender.total_deaths = death_label.text
		get_tree().change_scene_to_file("res://end_screen.tscn")
