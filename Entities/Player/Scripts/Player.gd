extends CharacterBody3D

@export var Sensitivity : float = 0.005

@export var Speed : float = 0.75
@export var Jump_Hieght : float = 4.5

@onready var Neck : Node3D = $Neck
@onready var Camera : Camera3D = $Neck/Camera

@onready var RayCast : RayCast3D = $"Neck/Camera/RayCast"
@onready var Target : Marker3D = $"Neck/Camera/Target"
@onready var Rotation_Target = $"Neck/Camera/Target/Rotation Target"

@onready var Animator : AnimationPlayer = $"Animator"
@onready var Crouch_RayCast : RayCast3D = $"Crouch"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var obj = null
var off_set : Vector3 = Vector3.ZERO

var Crouched : bool = false

func _ready():
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	

func _input(event):
	
	if event is InputEventMouseMotion:
		
		Neck.rotate_y(-event.relative.x * Sensitivity)
		Camera.rotate_x(-event.relative.y * Sensitivity)
		
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
	

func _physics_process(delta):
	
	if Input.is_action_just_pressed("Crouch"):
		
		Animator.stop()
		
		Animator.play("Crouch")
		
		Crouched = true
		
	elif  Input.is_action_just_released("Crouch"):
		
		Animator.stop(true)
		
	
	if Input.is_action_pressed("Crouch"):
		if Crouched == false:
			
			Animator.play("Crouch")
			
			Crouched = true
			
		
	elif !Input.is_action_pressed("Crouch"):
		
		if !Crouch_RayCast.is_colliding():
			
			if Crouched == true:
				
				Animator.play_backwards("Crouch")
				
				Crouched = false
				
	
	if obj == null:
		
		if RayCast.is_colliding():
			
			Target.global_position = RayCast.get_collision_point()
			
		else:
			
			Target.position = RayCast.target_position
			
	
	if Input.is_action_pressed("Grab"):
		
		if RayCast.is_colliding():
			
			if RayCast.get_collider().is_class("RigidBody3D"):
				
				if obj == null:
					print("S")
					Rotation_Target.global_rotation = RayCast.get_collider().global_rotation
					off_set = RayCast.get_collider().global_position - Target.global_position
					
					obj = RayCast.get_collider()
					
			
		
	elif Input.is_action_just_released("Grab"):
		
		if obj != null:
			obj.linear_velocity /= 2
			
			remove_collision_exception_with(obj)
			RayCast.remove_exception(obj)
			
			obj = null
		
	
	if obj != null:
		
		RayCast.add_exception(obj)
		add_collision_exception_with(obj)
		
		#obj.angular_velocity = (Rotation_Target.global_rotation - obj.global_rotation)
		
		obj.linear_velocity = ((Target.global_position + off_set) - obj.global_position) * 15 * distance(Target.global_position, obj.global_position)
		
		Rotation_Target.global_position = off_set
		
		if distance(self.global_position, obj.global_position) > 3:
			
			remove_collision_exception_with(obj)
			RayCast.remove_exception(obj)
			
			obj = null
			
		
	
	if is_on_floor():
		
		if Input.is_action_pressed("Jump"):
			
			velocity.y = Jump_Hieght
			
		
	else:
		
		velocity.y -= gravity * delta
		
	
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (Neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	if !Crouched:
		
		if Input.is_action_pressed("Sprint"):
			
			direction *= Speed * 1.25
			
		else:
			
			direction *= Speed
			
		
	else:
		
		direction *= (Speed / 2)
		
	if is_on_floor():
		
		velocity.x += direction.x
		velocity.z += direction.z
		
		velocity.x *= 0.8
		velocity.z *= 0.8
		
	else:
		
		velocity.x += direction.x / 3
		velocity.z += direction.z / 3
		
		velocity.x *= 0.95
		velocity.z *= 0.95
		
	
	move_and_slide()
	

func distance(a : Vector3, b : Vector3) -> float:
	
	return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2))
	
