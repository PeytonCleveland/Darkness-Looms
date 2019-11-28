extends KinematicBody2D

signal hit
signal dead

export (int) var speed
export (int) var health
export (float) var max_light_energy = 8
export (float) var min_light_energy = 1.5

var score = 0
var velocity = Vector2()
var multiplier = 1.0
var normalizer = 5
var sprint_val = 50
var can_shoot = true
var can_sprint = true
var alive = true
var light = null
var rng = RandomNumberGenerator.new()
var slomo = false
var slomo_spacer = 0
var teleport_anim_timer = Timer.new()


const FIRE_BULLET = preload("res://FireBullet.tscn")

func _ready():
	# Grab light info for future use
	light = get_node("Light2D")
	
	# Set up timer for Teleport animation
	teleport_anim_timer.set_wait_time(1)
	teleport_anim_timer.set_one_shot(false)
	self.add_child(teleport_anim_timer)
	teleport_anim_timer.start()
	$AnimatedSprite/TeleportAnimationOverlay.visible = false
		
	# Initialize random number generator
	rng.randomize()
	
func control(delta):
	#slo-mo
	if(slomo_spacer < 9):
		slomo_spacer += 1
	if (Input.is_action_pressed('slo-mo') && slomo_spacer == 9):
		slomo_spacer = 0
		if (!slomo):
			Engine.time_scale = 0.1
			slomo = true
		else:
			Engine.time_scale = 1
			slomo = false
			
	# Leap of faith
	if Input.is_action_just_pressed('teleport'):
		leap_of_faith()
		
	# Fire!
	if Input.is_action_just_pressed('fire'):
		fire()
		
	# Movement
	velocity = Vector2()
	multiplier = 1.0
	if Input.is_action_pressed('sprint'):
		if (can_sprint):
			multiplier = 2.0
			sprint_val -= 1
	else :
		sprint_val += 1
	
	var idle = true
	
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
		$AnimatedSprite.play('run')
		idle = false
	
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
		$AnimatedSprite.play('run_left')
		idle = false
	
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
		$AnimatedSprite.play('run_down')
		idle = false
	
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
		$AnimatedSprite.play('run')
		idle = false

	if (idle):
		$AnimatedSprite.play('idle')
		
	velocity = velocity.normalized() * speed * multiplier

	if (sprint_val == 0):
		can_sprint = false
	else:
		can_sprint = true

func _physics_process(delta):
	normalizer -= 1
	if(normalizer == 0 && !slomo):
	# Make the light flicker like a flame... sort of
		light.offset = Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5))
		light.texture_scale = rng.randf_range(1.2, 1.3)
		normalizer = 7
	#light.color = Color(rng.randf(), rng.randf(), rng.randf()) # psychadelic

	# Update GUI & music
	$Camera2D/VBoxContainer/Score.text = "Score: " + str(score)
	$Camera2D/VBoxContainer/Health.text = "Health: " + str(health)
	$"/root/MusicPlayer".set_hero_health(health)
	
	# Update light level based on health
	light.energy = min_light_energy + ((max_light_energy - min_light_energy) * (float(health) / 100.0))
	
	# Dead? Stop moving.
	if (health <= 0):
		alive = false
		$Camera2D/VBoxContainer/Health.text = "Health: ded"
		return

	# Check for player's inputs and do stuff
	control(delta)

	# Reposition character
	move_and_slide(velocity)

# Move the player to a random but valid spot on the map.
func leap_of_faith():
	
	$AnimatedSprite/TeleportAnimationOverlay.play('teleport_part1_overlay')
	$AnimatedSprite/TeleportAnimationOverlay.visible = true
	$TeleportSound.play()

	# Find the extents of the tilemap
	var tilemap = get_node("../TileMap")
	var min_x = tilemap.get_used_rect().position.x
	var min_y = tilemap.get_used_rect().position.y
	var max_x = tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x
	var max_y = tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y
	
	#print_debug(str(min_x) + ", " + str(min_y) + " to " + str(max_x) + ", " + str(max_y))
	
	var good_location = false;
	var new_x = 0 
	var new_y = 0
	
	# While we haven't found a good landing location, keep looking for one.
	while (!good_location):
		        
		# Pick random location on the tile map.
		new_x = rng.randi_range(min_x, max_x) 
		new_y = rng.randi_range(min_y, max_y)
		                
		# Determine if the location is good by checking if the tile type is a floor.
		# TODO: don't rely on hard-coded tile types to determine what is a suitable landing location
		if (tilemap.get_cell(new_x, new_y) == 60):
			good_location = true;
		
	#print_debug(str(new_x) + ", " + str(new_y))
		
	
	yield(teleport_anim_timer, "timeout")

	# Move the player to the new location in the center of the selected tile
	position = Vector2(new_x * tilemap.cell_size.x, new_y * tilemap.cell_size.y)	    
	
	$AnimatedSprite/TeleportAnimationOverlay.play('teleport_part2_overlay')

	# Penalty for using leap
	# TODO: make not hard-coded
	health -= 10

	yield(teleport_anim_timer, "timeout")
	
	$AnimatedSprite/TeleportAnimationOverlay.stop()
	$AnimatedSprite/TeleportAnimationOverlay.visible = false

	pass
	
# Shoot fire. Aiming = player's direction of travel. If not moving, don't fire. Where would it go?
func fire():
	# If player can shoot and IS moving, fire.
	if (can_shoot && (velocity.length() > 0)):

		# Penalty for firing
		# TODO: make not hard-coded
		health -= 2

		# Make a new bullet instance and send it off in the player's direction of travel
		# (i.e. aiming = direction moving)
		var fire_bullet = FIRE_BULLET.instance()
		get_parent().add_child(fire_bullet)
		fire_bullet.start(position, velocity)
		
	pass
