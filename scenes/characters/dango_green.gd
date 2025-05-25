extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction 
var boosterJump = 0
var leaver_floor: bool = false
var had_jump = false
var max_jump = 2
var count_jump = 0
var wait_animations: bool = false
var ray_cast = 30
var wall_jump: bool = false


func _physics_process(delta: float) -> void:
	
	# Reiniciar saltos.
	if is_on_floor():
		leaver_floor = false
		had_jump = false
		count_jump = 0
		wait_animations = false
	
	# Add the gravity.
	if not is_on_floor():
		if not leaver_floor:
			$Timer.start()
		velocity += get_gravity() * delta

	# Saltar.
	if Input.is_action_just_pressed("ui_accept") and right_to_jump():
		if count_jump == 1:
			wait_animations = true
			$AnimatedSprite2D.play("double_jump")
		count_jump += 1
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if $RayCast2D.get_collider():
		if $RayCast2D.get_collider().is_in_group("wall_jump"):
			if velocity.y > 0:
				velocity.y = 0
				count_jump = 0
				wall_jump = true
		else:
			wall_jump = false
	else:
		wall_jump = false
	
	animations()
	move_and_slide()
	print(count_jump)
	
func animations():
	
	if direction < 0:
		$RayCast2D.target_position.x = -ray_cast
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$RayCast2D.target_position.x = ray_cast
		$AnimatedSprite2D.flip_h = false
	
	if not wait_animations: 
		if wall_jump:
			$AnimatedSprite2D.play("jump_up")
		else:
			if velocity.x == 0:
				$AnimatedSprite2D.play("idle")
			elif velocity.x > 0:
				$AnimatedSprite2D.play("walk")
			elif velocity.x < 0:
				$AnimatedSprite2D.play("walk")
			
		
			if velocity.y > 0 || velocity.y < 0 :
				$AnimatedSprite2D.play("jump_up_center")
		
			if velocity.x > 0 && (velocity.y > 0 || velocity.y < 0):
				$AnimatedSprite2D.play("jump_up")
			elif velocity.x < 0 && (velocity.y > 0 || velocity.y < 0):
				$AnimatedSprite2D.play("jump_up")
			
		
		
func right_to_jump(): 
	# Verificar si el personaje puede saltar de acuerdo al estado actual
	if had_jump:
		if count_jump < max_jump: return true
		else: return false
	if is_on_floor() || wall_jump:
		had_jump = true
		return true
	elif not $Timer.is_stopped():
		had_jump = true
		return true
		
func _on_timer_timeout() -> void:
	#print("¡hey!")# Replace with function body.
	pass

func _on_animated_sprite_2d_animation_finished() -> void:
	wait_animations = false
