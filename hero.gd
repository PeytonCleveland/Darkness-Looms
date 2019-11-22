extends KinematicBody2D

signal hit
signal dead

export (int) var speed
export (int) var health

var velocity = Vector2()
var multiplier = 1.0
var sprint_val = 100
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
	# Make the light flicker like a flame... sort of
	light.offset = Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
	light.energy = orig_light_energy + rng.randf_range(-(orig_light_energy / 2), orig_light_energy / 2)
	#light.color = Color(rng.randf(), rng.randf(), rng.randf()) # psychadelic

	if not alive:
		return

	control(delta)
	move_and_slide(velocity)
