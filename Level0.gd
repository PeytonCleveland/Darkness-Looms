extends Node2D

const MusicPlayer = preload("MusicPlayer.gd") # Relative path
onready var music_player = MusicPlayer.new()

export (PackedScene) var Mob
var score

func _ready():
	randomize()
	$MobTimer.start()
	music_player._ready()
	
func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.set_offset(randi())
    # Create a Mob instance and add it to the scene.
	var mob = Mob.instance()
	add_child(mob)
    # Set the mob's direction perpendicular to the path direction.
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
    # Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position

