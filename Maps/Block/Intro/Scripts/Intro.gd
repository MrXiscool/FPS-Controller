extends Node

@onready var Animator : AnimationPlayer = $"Map/AnimationPlayer"

func _ready():
	
	Animator.play("Intro")
	
