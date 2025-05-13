extends Area2D

@export var heal_amount: int = 9
@export_enum("apple", "banana", "cheries", "morango")
var sprite: String = "apple"
var coletado: bool = false

func _ready():
	if not coletado:
		$AnimatedSprite2D.play(sprite)
	connect("body_entered", _on_body_enteded)
	$AnimatedSprite2D.connect("animation_finished", _on_animation_finished)

func _on_body_enteded(body):
	if coletado:
		return
	
	if body.name == "Jogador":
		coletado = true
		$AnimatedSprite2D.play("coletado")
		$CollisionShape2D.call_deferred("set_disabled", true)

func _on_animation_finished():
	if coletado and $AnimatedSprite2D.animation == "coletado":
		print("sumiu")
		queue_free()
