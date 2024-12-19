class_name Character

extends Node

@export var species : String
@export var health: int

func evaporate():
	health = 0
	print(species + " died.")
