extends Node

export (int) var music_layers_total = 6
<<<<<<< Updated upstream
var music_layers_active = 6
=======
var music_layers_active = 1
>>>>>>> Stashed changes
var music_stream_players = []
var last_health = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for bgm_layer in range (1, music_layers_total + 1):
		var music_file = "res://Assets/bgm/BGM Layer " + str(bgm_layer) + ".wav"
		var stream = AudioStream.new()
		var music_player = AudioStreamPlayer.new()
		if File.new().file_exists(music_file):
			var music = load(music_file)
			music_player.stream = music
			music_stream_players.push_back(music_player)
			#print_debug("loaded bgm layer: " + str(bgm_layer))
			
			# Create bus for new stream and connect to master bus
			var music_bus_id = AudioServer.get_bus_count()
			AudioServer.add_bus()
			AudioServer.set_bus_name(music_bus_id, "BGM" + str(bgm_layer))
			AudioServer.set_bus_send(music_bus_id, "Master")
			add_child(music_player)
			music_player.bus = "BGM" + str(bgm_layer)
			
	music_layers_play()
	
	pass # Replace with function body.
	
# Play all music layers. 
func music_layers_play():
	# start the music
	for bgm_layer in range (0, music_layers_total):
		#print_debug("play bgm layer: " + str(bgm_layer))
		music_stream_players[bgm_layer].play()
	
	music_layers_volume_set()
	
	pass	

# Turn background music layers on/off based on how many layers should be active
func music_layers_volume_set():
	#print_debug("Layers: " + str(music_layers_total) + " Active: " + str(music_layers_active))
	
	for bgm_layer in range(0, music_layers_active):
		#print_debug("Hear layer " + str(bgm_layer))
<<<<<<< Updated upstream
		music_stream_players[bgm_layer].volume_db = -15;
=======
		#normalize audio, make drums stand out, make flute soumd distant
		if (bgm_layer == 1):
			music_stream_players[bgm_layer].volume_db = -36
		elif (bgm_layer == 2):
			music_stream_players[bgm_layer].volume_db = -30
		elif (bgm_layer == 3):
			music_stream_players[bgm_layer].volume_db = -36
		elif (bgm_layer == 4):
			music_stream_players[bgm_layer].volume_db = -29
		elif (bgm_layer == 5):
			music_stream_players[bgm_layer].volume_db = -44
		else:
			music_stream_players[bgm_layer].volume_db = -20;
>>>>>>> Stashed changes
		
	for bgm_layer in range(music_layers_active, music_layers_total):
		#print_debug("Don't hear layer " + str(bgm_layer))
		music_stream_players[bgm_layer].volume_db = -80;
		
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Debug music
	if Input.is_action_just_pressed('music_build'):
		if (music_layers_active < music_layers_total):
			music_layers_active += 1
		music_layers_volume_set()
			
	if Input.is_action_just_pressed('music_unbuild'):
		if (music_layers_active > 1):
			music_layers_active -= 1
		music_layers_volume_set()
		
	# Music stopped? Restart it.
	if (!music_stream_players[0].is_playing()):
		music_layers_play()
		
	pass

# Match the music layers to the hero's health.
func set_hero_health(health):
	if (health == last_health):
		return
	last_health = health
	if (health <= 0):
		music_layers_active = 0
	else:
		music_layers_active = int(ceil((float(health) / 100.0) * float(music_layers_total)))
		if (music_layers_active < 1):
			music_layers_active = 1
		#print_debug("Health music layers: " + str((float(health) / 100.0) * float(music_layers_total)))
		#print_debug("Health music layers round: " + str(ceil((float(health) / 100.0) * float(music_layers_total))))
	music_layers_volume_set()
	pass
	