extends KinematicBody2D

signal hit
signal dead

export (int) var speed
export (int) var health

var velocity = Vector2()
var multiplier = 1.0
var normalizer = 5
var sprint_val = 50
var can_shoot = true
var can_sprint = true
var alive = true
var light = null
var orig_light_energy = 0
var rng = RandomNumberGenerator.new()

func _ready():
	# Save reference to light node for future use
	light = get_node("Light2D")
	orig_light_energy = light.energy
	# Initialize random number generator
	rng.randomize()
	
func control(delta):
	velocity = Vector2()
	multiplier = 1.0
	if Input.is_action_pressed('sprint'):
		if (can_sprint):
			multiplier = 2.0
			sprint_val -= 1
	else :
		sprint_val += 1
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
		$AnimatedSprite.play('run')
	elif Input.is_action_pressed('ui_left'):
		velocity.x -= 1
		$AnimatedSprite.play('run_left')
	elif Input.is_action_pressed('ui_down'):
		velocity.y += 1
		$AnimatedSprite.play('run_down')
	elif Input.is_action_pressed('ui_up'):
		velocity.y -= 1
		$AnimatedSprite.play('run')
	else:
		$AnimatedSprite.play('idle')
	velocity = velocity.normalized() * speed * multiplier
	if (sprint_val == 0):
		can_sprint = false
	else:
		can_sprint = true

func _physics_process(delta):
	normalizer -= 1
	if(normalizer == 0):
	# Make the light flicker like a flame... sort of
		light.offset = Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5))
		light.texture_scale = rng.randf_range(1.2, 1.3)
		light.energy = orig_light_energy + rng.randf_range(-(orig_light_energy / 4), orig_light_energy / 4)
		normalizer = 7
	#light.color = Color(rng.randf(), rng.randf(), rng.randf()) # psychadelic

	if not alive:
		return

	control(delta)
	move_and_slide(velocity)
