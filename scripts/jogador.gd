extends CharacterBody2D

@onready var CoyoteTimer: Timer = $CoyoteTimer
@onready var BufferPuloTimer: Timer = $BufferPuloTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var step_sound: AudioStreamPlayer2D = $StepSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

var coyteTimeActivated: bool = false

const jumpHeight: float = -230.0
var gravity: float = 8.0
const maxGravity: float = 14.5

const maxSpeed: float = 100.0
const acceleration: float = 10.0
const friction: float = 10


func _physics_process(delta: float) -> void:
	var x_input: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var velocityWeight: float = delta * (acceleration if x_input else friction)
	velocity.x = lerp(velocity.x, x_input * maxSpeed, velocityWeight)
	
	if is_on_floor():
		coyteTimeActivated = false
		gravity = lerp(gravity, 12.0 ,12.0 * delta)
	else: 
		if CoyoteTimer.is_stopped() and !coyteTimeActivated:
			CoyoteTimer.start()
			coyteTimeActivated = true
		
		if Input.is_action_just_released("jump") or is_on_ceiling():
			velocity.y *= 0.5
		
		gravity = lerp(gravity, maxGravity, 12.0 * delta)
	
	if Input.is_action_just_pressed("jump"):
		
		if BufferPuloTimer.is_stopped():
			BufferPuloTimer.start()
	
	if !BufferPuloTimer.is_stopped() and (!CoyoteTimer.is_stopped() or is_on_floor()):
		$AnimatedSprite2D.play("idle")
		velocity.y = jumpHeight
		BufferPuloTimer.stop()
		CoyoteTimer.stop()
		coyteTimeActivated = true
		jump_sound.play()
	
	if velocity.y < jumpHeight/2.0:
		var colisaoCabeca: Array = [$CantoSuperioEsquerdoD.is_colliding(), $CantoSuperioEsquerdoF.is_colliding(), $CantoSuperioDireitoF.is_colliding(), $CantoSuperioDireitoD.is_colliding()]
		if colisaoCabeca.count(true) == 1:
			if colisaoCabeca[0]:
				global_position.x += 1.75
			if colisaoCabeca[2]:
				global_position.x -= 1.75
	
	if velocity.y > -30 and velocity.y < -5 and abs(velocity.x) > 3:
		if $LeftLedgeHop2.is_colliding() and !$LeftLedgeHop3.is_colliding() and velocity.x < 0:
			velocity.y += jumpHeight/3.25
		if $RightLedgeHop.is_colliding() and !$RightLedgeHop2.is_colliding() and velocity.x > 0:
			velocity.y += jumpHeight/3.25
	
	velocity.y += gravity
	
	move_and_slide()
	
	# ANIMAÇÕES
	if !is_on_floor():
		if velocity.y < 0:
			sprite.play("pular")
		else:
			sprite.play("cair")
	elif abs(velocity.x) > 1:
		sprite.play("andar")
		if !step_sound.playing:
			step_sound.play()
	else:
		sprite.play("idle")
		step_sound.stop()

	# INVERTE SPRITE
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
