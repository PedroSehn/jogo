extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 900.0

var is_jumping: bool = false
var on_hit: bool = false

func _physics_process(delta):
	var velocity = self.velocity

	# Aplicar gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# Movimento horizontal
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = direction * speed


	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true


	# Virar sprite
	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0
	
 	
	if direction != 0:
		$AnimatedSprite2D.play("andar")
	else:
		$AnimatedSprite2D.play("idle")

	if is_jumping and !is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("pular")
		else:
			$AnimatedSprite2D.play("cair")

	self.velocity = velocity
	move_and_slide()
