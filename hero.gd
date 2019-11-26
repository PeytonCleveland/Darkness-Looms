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
var slomo = false
var slomo_spacer = 0


func _ready():
	# Grab light info for future use
	light = get_node("Light2D")
	#light.energy = ((music_player.music_layers_active - 1) * 3) + 1
	orig_light_energy = light.energy

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
		
	# Movement
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
	if(normalizer == 0 && !slomo):
	# Make the light flicker like a flame... sort of
		light.offset = Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5))
		light.texture_scale = rng.randf_range(1.2, 1.3)
		#light.energy = orig_light_energy + rng.randf_range(-(orig_light_energy / 4), orig_light_energy / 4)
		normalizer = 7
	#light.color = Color(rng.randf(), rng.randf(), rng.randf()) # psychadelic

	if not alive:
		return

	control(delta)
	move_and_slide(velocity)

# Move the player to a random but valid spot on the map.
func leap_of_faith():
	
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
		
	# Move the player to the new location in the center of the selected tile
	position = Vector2(new_x * tilemap.cell_size.x, new_y * tilemap.cell_size.y)	    
	
	pass
	

