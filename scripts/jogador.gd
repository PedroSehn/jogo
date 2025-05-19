extends CharacterBody2D

@onready var CoyoteTimer: Timer = $CoyoteTimer
@onready var BufferPuloTimer: Timer = $BufferPuloTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

var vivo: bool = true
var coyteTimeActivated: bool = false

const jumpHeight: float = -230.0
var gravity: float = 8.0
const maxGravity: float = 14.5

const maxSpeed: float = 100.0
const acceleration: float = 10.0
const friction: float = 10

func _ready():
	add_to_group("jogador")

func _physics_process(delta: float) -> void:
	if !vivo:
		return
	
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
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider().is_in_group("enemy"):
			if global_position.y < col.get_collider().global_position.y - 10:
			# Está acima do inimigo (vai matar ele via _on_head_hit)
				pass
			else:
				#morrer()
				print('morre')

	
	# ANIMAÇÕES
	if !is_on_floor() and vivo:
		if velocity.y < 0:
			sprite.play("pular")
		else:
			sprite.play("cair")
	elif abs(velocity.x) > 1 and vivo:
		sprite.play("andar")
	else:
		sprite.play("idle")
		
		

	# INVERTE SPRITE
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


func matar():
	if !vivo:
		return
	$DeathSound.play()
	sprite.play("dano")
	vivo = false
	await animacao_morte()
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(0.7).timeout
	get_tree().reload_current_scene()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group('inimigo'):
		matar()


func animacao_morte():
	var start_position = position
	var up_position = start_position - Vector2(0, 25)
	var down_position = start_position + Vector2(0, 4)
	
	while position.y > up_position.y:
		position.y -= 2
		position.x -= 1
		await get_tree().create_timer(0.01).timeout
	
	#while position.x > 15:
		#position.x -= 2
		#await get_tree().create_timer(0.01).timeout
	
	while position.y < down_position.y:
		position.y += 4
		position.x -= 1
		await get_tree().create_timer(0.01).timeout
