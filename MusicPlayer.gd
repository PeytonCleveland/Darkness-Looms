extends Node

export (int) var music_layers_total = 6
var music_layers_active = 2
var music_stream_players = []

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
		music_stream_players[bgm_layer].volume_db = -10;
		
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
		#light.energy = ((music_layers_active - 1) * 3) + 1
		#orig_light_energy = light.energy
		music_layers_volume_set()
			
	if Input.is_action_just_pressed('music_unbuild'):
		if (music_layers_active > 1):
			music_layers_active -= 1
		#light.energy = ((music_layers_active - 1) * 3) + 1
		#orig_light_energy = light.energy
		music_layers_volume_set()
		
	# Music stopped? Restart it.
	if (!music_stream_players[0].is_playing()):
		music_layers_play()
		
	pass
