extends Node

## this code was written following the video by brackeys
## https://www.youtube.com/watch?v=e1zJS31tr88&t=2684s&ab_channel=Brackeys

## nodes are classes, scripts are also like classes

# static typing of the variable
# the @export decorator allows you to set the value of a variable using the inspector
@export var fruits: float = 0
@export var player_alignment: Alignment
@export var character_sprite: Sprite2D
@export var character_to_attack: Character

signal photons_changed(new_photons)
signal stamina_changed(new_stamina)
signal flooded(msg)


# setter value

## initial chance value
var chance := 0.2
var chance_pct: int:
	# return the chance percentage based on a change in the chance
	get:
		return chance * 100
	# set the chance based on the percentage
	set(value):
		chance = float(value) / 100.0

# setter example
var photons := 100:
	set(value):
		photons = clamp(value, 0, 100)
		photons_changed.emit(photons)

var stamina := 100:
	set(value):
		stamina = clamp(value, 0, 100)
		stamina_changed.emit(stamina)

var flood_counter := 0

# constants just as an example
const gravity :float = 9.8

enum Alignment { NEUTRAL, PREDATOR, PREY  }

## accessing a weapon only once it has been loaded
@onready var weapon = $Player/weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	print(chance_pct)
	chance_pct = 40
	print(chance_pct)
	# setup
	$title.text = "flood"
	$title.modulate = Color.WHITE_SMOKE
	$"photons/photon-label".modulate = Color.YELLOW
	$"stamina/stamina-label".modulate = Color.GREEN_YELLOW
	$"fruits/fruit-count".modulate = Color.YELLOW_GREEN
	
	flooded.connect(_on_flooded)
	
	# data types dictionary
	var fruit_types = {
		"berry": {"photon_bonus": 15, "stamina_cost": 5},
		"banana": {"photon_bonus": 30, "stamina_cost": 30},
		"apple": {"photon_bonus": 15, "stamina_cost": 5}
	}
	
	# switch case
	match player_alignment:
		Alignment.PREDATOR:
			print("++")
		Alignment.PREY:
			print("--")
		Alignment.NEUTRAL:
			print("==")
		_:
			print("ghost")
	
	character_to_attack.evaporate()

func _input(event):
	if event.is_action_pressed("move"):
		if(stamina > 0):
			$title.text = "[_] you jumped!"
			stamina -= 5
		else:
			$title.text = "please rest!"
	
	if event.is_action_pressed("beam"):
		if photons > 0 and stamina > 0:
			$title.text = "[x] photon beam!"
			photons -= 5
			stamina -= 1
			var item_search = randf()
			var metric = randi_range(0, 360)
			if item_search <= 0.8:
				if metric > 0 and metric < 90:
					$"item-text".text = str(metric) + "° E"
				elif metric > 90 and metric < 180:
					$"item-text".text = str(metric) + "° S"
				elif metric > 180 and metric < 270:
					$"item-text".text = str(metric) + "° W"
				else:
					$"item-text".text = str(metric) + "° N"
			else:
				fruits += 1
				$"fruits/fruit-count".text = str(fruits)
				$"item-text".text = "you found a fruit!"
		else:
			if stamina == 0:
				$title.text = "please rest!"
			if photons == 0:
				$title.text = "you evaporated!"
	
	if event.is_action_pressed("rest"):
		$title.text = "[z] you rested!"
		if stamina < 100:
			stamina += 5
		if photons < 100:
			photons += 5
			

# static typing syntax
func add(num1: int, num2: int) -> int:
	var result = num1 + num2
	return result
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if photons <= 0 or stamina <= 0:
		photons = 5
		stamina = 5
		$title.text = "you materialized"
	if stamina > 100:
		stamina = 100
	pass

# example of a signal
func _on_ui_pressed() -> void:
	$title.text = "clap!"
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	flood_counter += 5
	print(flood_counter)
	if(flood_counter > 20):
		flood_counter = 0
		flooded.emit("warning::flood!!")
	pass # Replace with function body.


func _on_flooded(msg: Variant) -> void:
	$flood_warning.text = msg


func _on_photons_changed(new_photons: Variant) -> void:
	$"photons/photon-count".text = str(photons)
	pass # Replace with function body.


func _on_stamina_changed(new_stamina: Variant) -> void:
	$"stamina/stamina-count".text = str(stamina)
	pass # Replace with function body.
