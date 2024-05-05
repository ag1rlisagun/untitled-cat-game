extends CharacterBody2D

# need logic for regular speed, sprint speed and stamina
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@onready var cshape = $CollisionShape2D

var selected = false
var crouching = false
var has_idled = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Get the character's two collision shapes for crouching and standing
var standing_cshape = preload("res://Resources/cat_standing.tres")
var crouching_cshape = preload("res://Resources/cat_crawling.tres")

# change to AnimatedSprite2D after animating needed sprites
@onready var animated_sprite = $AnimatedSprite2D

func _on_area_2d_input_event(viewport, event, shape_idx):
	if !Input.is_action_pressed("click"):
		selected = false
	else:
		selected = true
		
func crouch():
	if !is_on_floor():
		return
	if crouching:
		return
	crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = -17
	
func stand():
	if !crouching:
		return
	crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = -28

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 8 * delta)
		animated_sprite.play("carry")
	else:
		# GRAVITY
		if not is_on_floor():
			velocity.y += gravity * delta
			has_idled = false
			$Timer.start()

		# JUMP
		# can add double jump/wall jump/etc.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY 
			has_idled = false
			$Timer.start()

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		# need to add logic for sprite animations (walking, running, jump+dbl, climb, crouch)
		var direction = Input.get_axis("move_left", "move_right")
		
		# ⭐️TODO: FOR ANIMATING SPRITES
		# SIDE IDLE ANIMATION IF CAT MOVED WITHIN 10 SECONDS
		# FRONT SITTING IDLE ANIMATION IF CAT HASN'T MOVED FOR 10 SECONDS
		
		# Flip Sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
			
		# Crouching
		if Input.is_action_pressed("crouch"):
			crouch()
		elif Input.is_action_just_released("crouch"):
			stand()
		
		if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right") or Input.is_action_just_released("crouch"):
			has_idled = false
			$Timer.start()
			
		# Play Animations
		if is_on_floor():
			if direction == 0:
				if has_idled:
					animated_sprite.play("idle")
				elif !has_idled:
					animated_sprite.play("side idle")
				if crouching:
					animated_sprite.play("crouch")
				if Input.is_action_just_pressed("jump"):
					animated_sprite.play("jump")
			else:
				if !crouching:
					if Input.is_action_pressed("sprint"):
						animated_sprite.play("sprint")
					else:
						animated_sprite.play("move")
				else:
					animated_sprite.play("crawl")
				if Input.is_action_just_pressed("jump"):
					animated_sprite.play("jump")
		else:
			if velocity.y > 0:
				animated_sprite.play("fall")  # Play falling animation when not on floor
		
		# Applies movement
		if direction:
			if Input.is_action_pressed("sprint") && !crouching: 
				velocity.x = direction * SPEED * 2
			else:
				velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()


func _on_timer_timeout():
	has_idled = true
