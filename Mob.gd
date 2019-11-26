extends KinematicBody2D

export (int) var min_speed # Minimum speed range.
export (int) var max_speed # Maximum speed range.
var mob_types = ["orc", "ogre"]

func _ready():
    $AnimatedSprite.animation = mob_types[randi() % mob_types.size()]

