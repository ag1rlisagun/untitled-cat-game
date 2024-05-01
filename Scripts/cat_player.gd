extends CharacterBody2D

# need logic for regular speed, sprint speed and stamina
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# change to AnimatedSprite2D after animating needed sprites
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# GRAVITY
	if not is_on_floor():
		velocity.y += gravity * delta

	# JUMP
	# can add double jump/wall jump/etc.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# need to add logic for sprite animations (walking, running, jump+dbl, climb, crouch)
	var direction = Input.get_axis("move_left", "move_right")
	
	# FOR ANIMATING SPRITES: 
	# SIDE IDLE ANIMATION IF CAT MOVED WITHIN 10 SECONDS
	# FRONT SITTING IDLE ANIMATION IF CAT HASN'T MOVED FOR 10 SECONDS
	# BRISK WALK ANIMATION IF MOVING
	# SPRINT ANIMATION IF MOVING WITH SHIFT
	# CRAWL ANIMATION IF MOVING LEFT/RIGHT WITH DOWN ARROW
	
	# Flip Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
#	# Play Animations
#	if is_on_floor():
#		if Input.is_action_just_pressed("jump"):
#			animated_sprite.play("jump")
#		if direction == 0:
#			animated_sprite.play("side idle")
#		elif direction != 0:
#			if Input.is_action_just_pressed("sprint"):
#				animated_sprite.play("sprint")
#			else:
#				animated_sprite.play("move")
##	else:
##		animated_sprite.play("fall")

 # Play Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("side idle")
			if Input.is_action_just_pressed("jump"):
				animated_sprite.play("jump")
		else: 
			if Input.is_action_just_pressed("jump"):
				animated_sprite.play("jump")
			elif Input.is_action_pressed("sprint"):
				animated_sprite.play("sprint")
			else:
				animated_sprite.play("move")
	else:
		if velocity.y > 0:
			animated_sprite.play("fall")  # Play falling animation when not on floor
	
	# Applies movement
	if direction:
		if Input.is_action_pressed("sprint"): 
			velocity.x = direction * SPEED * 2
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
