extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 600.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_area: Area2D = $AreaCabeca

var direction := -1 # começa andando pra esquerda
var alive := true
var dying := false

func _ready():
	add_to_group("inimigo")
	head_area.body_entered.connect(_on_head_hit)

func _physics_process(delta):
	if dying:
		velocity.y += gravity * delta
		velocity.x = 0
		move_and_slide()
		return
		
	
	if !alive:
		return

	# Aplica gravidade
	velocity.y += gravity * delta
	velocity.x = direction * speed

	# Verifica se vai cair em buraco ou bater na parede
	if !$RayCast2D.is_colliding() and is_on_floor() or $FrontCheck.is_colliding():
		_flip()

	move_and_slide()


func _flip():
	if direction == -1:
		direction = 1
	else:
		direction = -1
	scale.x = -scale.x
#d	ground_check.position.x *= -1

func _on_head_hit(body):
	if body.is_in_group("jogador"):  # certifique-se de adicionar seu jogador a esse grupo
		die()
		body.velocity.y = -200  # rebate o jogador pra cima ao pular na cabeça

func die():
	alive = false
	dying = true
	
	$CollisionShape2D.call_deferred("set_disabled", true)
	head_area.call_deferred("set_monitoring", false)
	$RayCast2D.call_deferred("set_monitoring", false)
	$FrontCheck.call_deferred("set_monitoring", false)
	
	velocity = Vector2(0, 150)  # impulso pra cima
	sprite.play("hit")  # você precisa de uma animação chamada "death"
	$Deadthsound.play()
	
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _on_area_cabeca_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
