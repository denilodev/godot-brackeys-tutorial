extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var is_alive = true
var actual_rolling_state = false
enum {LEFT = -1, NONE = 0, RIGHT = 1}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var roll_collision_shape_2d: CollisionShape2D = $RollCollisionShape2D

func _physics_process(delta: float) -> void:
	
	if is_alive:
		var direction := Input.get_axis("move_left", "move_right")
		handle_jump()
		handle_roll(direction)
		handle_moviment(direction)
		play_animations(direction)
		sprite_flip(direction)
	
	handle_gravity(delta)
	move_and_slide()

func die():
	animated_sprite.play("die")
	is_alive = false

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_roll(direction: float) -> void:
	if Input.is_action_just_pressed("roll") and direction != NONE:
		change_rolling_state(true)
	if is_rolling():
		if not is_on_floor():
			change_rolling_state(false)

func play_animations(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
		return
	
	if is_rolling():
		animated_sprite.play("roll")
		return
	
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

func sprite_flip(direction: float) -> void:
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_moviment(direction: float) -> void:
	if is_rolling() and direction == 0:
			# perpetuate the moviment to
			# the side player is looking
			if animated_sprite.flip_h == false:
				direction = RIGHT
			else:
				direction = LEFT
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	

func is_rolling() -> bool:
	return actual_rolling_state

func change_rolling_state(state: bool) -> void:
	actual_rolling_state = state
	collision_shape_2d.disabled = state
	roll_collision_shape_2d.disabled = !state

func _on_animated_sprite_2d_animation_finished() -> void:
	change_rolling_state(false)
