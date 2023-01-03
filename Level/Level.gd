extends Node2D


onready var pickups  = $Pickups


func _ready():
	pickups.hide()
	$Player.start($PlayerSpawn.position)
