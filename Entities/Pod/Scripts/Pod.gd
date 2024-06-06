extends Node3D

@onready var Animator : AnimationPlayer = $"AnimationPlayer"

func _ready():
	
	Animator.play("Flicker")
	
