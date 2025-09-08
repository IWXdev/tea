extends CharacterBody2D

@export var health = 100
@export var stamina = 100
@export var speed = 200
@export var jump_velocity = -300
@export var wall_slide_speed = 50
@export var wall_jump_force = Vector2(200, -300)

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var healthbar = $"../ui/healthbar"
@onready var stam = $"../ui/stamina"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float
var dash_time = 0.0
var attacking = false
var damag = 10
var dead = false

var on_wall = false
var wall_dir = 0 

func _ready() -> void:
	healthbar.value = health
	stam.value = stamina



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("damag"):
		health -= damag
		healthbar.value = health

	stam.value = stamina

	if stamina < 100:
		if direction == 0:
			stamina += 0.1

	if health == 0:
		dead = true

	if dash_time <= 0:
		move()

	jump()
	dash(delta)
	Attack()
	check_wall()


	if on_wall and not is_on_floor() and velocity.y > 0:
		velocity.y = wall_slide_speed


		if Input.is_action_just_pressed("jump"):
			velocity = Vector2(-wall_dir * wall_jump_force.x, wall_jump_force.y)


	animation()


	move_and_slide()


func move():
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		$Marker2D.scale.x = direction
		$Marker2D2.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)


func dash(delta):
	if stamina > 30:
		if Input.is_action_just_pressed("Dash") and dash_time <= 0:
			dash_time = 1
			stamina -= 30
		
		if dash_time > 0:
			dash_time -= delta
			velocity.x = direction * 400



func jump():
	if stamina > 10:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			stamina -= 10


func Attack():
	if stamina > 20:
		if Input.is_action_just_pressed("attack"):
			attacking = true
			stamina -= 20


func animation():
	if dead:
		anim.play("dead")
		return
	
	if dash_time > 0:
		anim.play("dash")
		return
	
	elif attacking:
		anim.play("attack")
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
	
	if is_on_floor():
		if direction != 0:
			anim.play("run")
		else:
			anim.play("idle")



func check_wall():
	on_wall = false
	wall_dir = 0

	if direction != 0 and not is_on_floor():
		var space_state = get_world_2d().direct_space_state


		var ray = PhysicsRayQueryParameters2D.new()
		ray.from = global_position
		ray.to = global_position + Vector2(direction * 8, 0)
		ray.exclude = [self]

		var result = space_state.intersect_ray(ray)
		if result:
			on_wall = true
			wall_dir = direction



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		attacking = false
	if anim_name == "daed":
		get_tree().reload_current_scene()
