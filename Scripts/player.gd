extends CharacterBody2D #Parent Node

#EXPORT VARIABLES
@export var speed = 200 # used for speed calculations
@export var speedMultiplier = 30 #how much the character velocity will increase / decrease by
@export var gravity = 10 #used to pull player down
@export var jumpspeed = 120 #used to calculate players upward momentum during jump

#COUNTERS
var coin_count = 0
var death_count = 0

#TIMER
var timer_active = true
var seconds = 0 #tracks seconds past

#Nodes -> variables
@onready var coin_label: Label = get_node("/root/Game/UI/CoinLabel")
@onready var death_label: Label = get_node("/root/Game/UI/DeathCounter")
@onready var time_label: Label = get_node("/root/Game/UI/Stopwatch")
@onready var finish_area: Area2D = $Finish

#USED TO SET SPAWN
var spawn_position: Vector2

#MOVEMENT
var wallslide = 4 #used to calculate wallslide speed
var last_direction = 1 #stores the direction the character most recently faced
var last_walljump = 0 #stores which side was last walljumped off



func _ready():
	
	spawn_position = global_position # set spawn location where I placed the character in the scene editor

func _physics_process(_delta: float) -> void:
	
	var was_on_floor #tracks if player was on the floor
	var direction : Vector2 #tracks player direction

#SETS DIRECTION BASED ON INPUT
	if Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
	else:
		direction.x = 0

#VELOCITY CALCULATION FOR SPRINTING		
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
			
#VELOCITY CALULATION IF WALKING
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

	#JUMPING ON GROUND
	if Input.is_action_just_pressed("jump") and (is_on_floor() or !$CoyoteTimer.is_stopped()):
		$Jump.play()
		velocity.y = -270

#GRAVITY WHEN NOT TOUCHING FLOOR
	if !is_on_floor():
		velocity.y += gravity

#WALLJUMP / SLIDE
	if is_on_wall() and !is_on_floor() and $WalljumpTimer.is_stopped(): #run if on wall, not touching floor, and walljump timer is stopped
		var wall_normal = get_wall_normal() #gets the normal force

		if !Input.is_action_just_pressed("jump") and velocity.y > 0: #if not jumping and velocity is down
			velocity.y = gravity * wallslide # multiply gravity by wallslide multiplier
			#SETS SPEED DEPENDING ON DIRECTION ALLOWING YOU TO FALL OFF WALL IF OPPOSITE DIRECTION PRESSED
			if Input.is_action_pressed("left"):
				velocity.x = -speed
			elif Input.is_action_pressed("right"):
				velocity.x = speed
			else:
				velocity.x = 0

#When Jumping
		if Input.is_action_just_pressed("jump"):
			$WalljumpTimer.start() #start wall jump timer
			$Jump.play() #plays jump sound
			#BOOSTS BOTH HORIZONTAL AND VERTICLE FORCES AND QUICKLY LAUNCHES PLAYER
			velocity.x = wall_normal.x * 320 
			velocity.y = -200
			
			#sets last_walljump to the normal force
			last_walljump = wall_normal.x

	
	was_on_floor = is_on_floor() #sets was on floor to true if on floor else false

	
	move_and_slide() #allows movement
	
	if was_on_floor and !is_on_floor() and !is_on_wall():#starts the coyote time if player was on floor but is no longer touching anything
		$CoyoteTimer.start()
	elif is_on_wall() and !is_on_floor() and velocity.y >= 0: #does wallslide animation
		wallslide_anim(direction.x)
	elif Input.is_action_just_pressed("jump") or !is_on_floor(): #does jump animation when jumping or freefalling
		jump_anim(direction.x)
	elif Input.is_action_pressed("run") and direction.length() > 0: #does run animation when running
		last_direction = direction.x
		run_anim(direction.x)
	elif abs(direction.x) > 0: #does walk animation if non of the above are true and direction isnt 0
		last_direction = direction.x #I did the absolute value thing as experimentation but direction.x != 0 works too
		walk_anim(direction.x)
	else: #if no inputs and on floor do idle
		idle_anim(last_direction)
		
	if timer_active and $TimerDelay.is_stopped(): #updates the timer at the top of screen if it's active
		seconds += 1 #adds one to seconds
		time_label.text = str(seconds) + "s" #updates the text block with the time
		$TimerDelay.start() #a one second delay to make the timer accurate
		
	
func add_coin():
	coin_count += 1 #add one to coin count
	$CollectCoin.play() #plays the coin collection sound
	coin_label.text = "Coins: " + str(coin_count) #updates the text block with new coin count

func respawn():
	$Death.play() #plays death sound
	death_count += 1 #updates death count
	global_position = spawn_position #makes your position, your spawn point
	death_label.text = "Deaths: " + str(death_count) #adds one to the death count
	velocity = Vector2.ZERO #removes your velocity to prevent movement glitches

#ANIMATIONS BASED ON DIRECTIONS
func wallslide_anim(direction): #wallslide animation 
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("wallslide")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("wallslide")

func jump_anim(direction):
	var anim_direction = direction #sets the animation direction to current direction

	if last_walljump != 0: #runs if walljumped
		anim_direction = last_walljump #sets the animation direction to lastwall jump direciton
		$PlayerAnimation.flip_h = anim_direction < 0 #sets true or false based on direction being bigger or smaller than 0
		$PlayerAnimation.play("jump") #plays jump animation
		last_walljump = 0 #sets last walljump to 0

	if anim_direction == 0: #if animation direction is 0
		anim_direction = last_direction #sets animation direction to the last direction
	$PlayerAnimation.flip_h = anim_direction < 0 
	$PlayerAnimation.play("jump")
		
#Run animation depending on direction pressed
func run_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("run")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("run") 
	
#works same as run_anim but plays walk animation instead
func walk_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("walk")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("walk")

#same as run animation but uses the last direction and plays the idle animation
func idle_anim(direction):
	if direction < 0:
		$PlayerAnimation.flip_h = true
		$PlayerAnimation.play("idle")
	if direction > 0:
		$PlayerAnimation.flip_h = false
		$PlayerAnimation.play("idle")

#runs when entering finish area
func _on_finish_body_entered(body: Node2D) -> void:
	if body == self: #checks if the player entered the finish
		timer_active = false #stops timer
		#Updates nodesender script's variables with run stats
		Nodesender.final_time = time_label.text
		Nodesender.total_coins = coin_label.text
		Nodesender.total_deaths = death_label.text
		#changes to end screen
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
